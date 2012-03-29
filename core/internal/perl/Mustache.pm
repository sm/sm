# Template::Mustache is an implementation of the fabulous Mustache templating
# language for Perl 5.8 and later.
#
# @author Pieter van de Bruggen
# @see http://mustache.github.com
package Template::Mustache;
use strict;
use warnings;

use CGI ();
use File::Spec;

use version 0.77; our $VERSION = qv("v0.5.1");

my %TemplateCache;

# Constructs a new regular expression, to be used in the parsing of Mustache
# templates.
# @param [String] $otag The tag opening delimiter.
# @param [String] $ctag The tag closing delimiter.
# @return [Regex] A regular expression that will match tags with the specified
#   delimiters.
# @api private
sub build_pattern {
    my ($otag, $ctag) = @_;
    return qr/
        (.*?)                       # Capture the pre-tag content
        ([ \t]*)                    # Capture the pre-tag whitespace
        (?:\Q$otag\E \s*)           # Match the opening of the tag
        (?:
            (=)   \s* (.+?) \s* = | # Capture Set Delimiters
            ({)   \s* (.+?) \s* } | # Capture Triple Mustaches
            (\W?) \s* (.+?)         # Capture everything else
        )
        (?:\s* \Q$ctag\E)           # Match the closing of the tag
    /xsm;
}

# Reads a file into a string, returning the empty string if the file does not
# exist.
# @param [String] $filename The name of the file to read.
# @return [String] The contents of the given filename, or the empty string.
# @api private
sub read_file {
    my ($filename) = @_;
    return '' unless -f $filename;

    local *FILE;
    open FILE, $filename or die "Cannot read from file $filename!";
    sysread(FILE, my $data, -s FILE);
    close FILE;

    return $data;
}

# @overload parse($tmpl)
#   Creates an AST from the given template.
#   @param [String] $tmpl The template to parse.
#   @return [Array] The AST represented by the given template.
#   @api private
# @overload parse($tmpl, $delims)
#   Creates an AST from the given template, with non-standard delimiters.
#   @param [String] $tmpl The template to parse.
#   @param [Array<String>[2]] $delims The delimiter pair to begin parsing with.
#   @return [Array] The AST represented by the given template.
#   @api private
# @overload parse($tmpl, $delims, $section, $start)
#   Parses out a section tag from the given template.
#   @param [String] $tmpl The template to parse.
#   @param [Array<String>[2]] $delims The delimiter pair to begin parsing with.
#   @param [String] $section The name of the section we're parsing.
#   @param [Int] $start The index of the first character of the section.
#   @return [(String, Int)] The raw text of the section, and the index of the
#       character immediately following the close section tag.
#   @api internal
sub parse {
    my ($tmpl, $delims, $section, $start) = @_;
    my @buffer;

    # Pull the parse tree out of the cache, if we can...
    $delims ||= [qw'{{ }}'];
    my $cache = $TemplateCache{join ' ', @$delims} ||= {};
    return $cache->{$tmpl} if exists $cache->{$tmpl};

    my $error = sub {
        my ($message, $errorPos) = @_;
        my @lineCount = split("\n", substr($tmpl, 0, $errorPos));

        die $message . "\nLine " . length(@lineCount);
    };

    # Build the pattern, and instruct the regex engine to begin at `$start`.
    my $pattern = build_pattern(@$delims);
    my $pos = pos($tmpl) = $start ||= 0;

    # Begin parsing out tags
    while ($tmpl =~ m/\G$pattern/gc) {
        my ($content, $whitespace) = ($1, $2);
        my $type = $3 || $5 || $7;
        my $tag  = $4 || $6 || $8;

        # Buffer any non-tag content we have.
        push @buffer, $content if $content;

        # Grab the index for the end of the content, and update our pointer.
        my $eoc = $pos + length($content) - 1;
        $pos = pos($tmpl);

        # A tag is considered standalone if it is the only non-whitespace
        # content on a line.
        my $is_standalone = (substr($tmpl, $eoc, 1) || "\n") eq "\n" &&
                            (substr($tmpl, $pos, 1) || "\n") eq "\n";

        # Standalone tags should consume the newline that follows them, unless
        # the tag is of an interpolation type.
        # Otherwise, any whitespace we've captured should be added to the
        # buffer, and the end of content index should be advanced.
        if ($is_standalone && ($type ne '{' && $type ne '&' && $type ne '')) {
            $pos += 1;
        } elsif ($whitespace) {
            $eoc += length($whitespace);
            push @buffer, $whitespace;
            $whitespace = '';
        }

        if ($type eq '!') {
            # Comment Tag - No-op.
        } elsif ($type eq '{' || $type eq '&' || $type eq '') {
            # Interpolation Tag - Buffers the tag type and name.
            push @buffer, [ $type, $tag ];
        } elsif ($type eq '>') {
            # Partial Tag - Buffers the tag type, name, and any indentation
            push @buffer, [ $type, $tag, $whitespace ];
        } elsif ($type eq '=') {
            # Set Delimiter Tag - Changes the delimiter pair and updates the
            # tag pattern.
            $delims = [ split(/\s+/, $tag) ];

            $error->("Set Delimiters tags must have exactly two values!", $pos)
                if @$delims != 2;

            $pattern = build_pattern(@$delims);
        } elsif ($type eq '#' || $type eq '^') {
            # Section Tag - Recursively calls #parse (starting from the current
            # index), and receives the raw section string and a new index.
            # Buffers the tag type, name, the section string and delimiters.
            (my $raw, $pos) = parse($tmpl, $delims, $tag, $pos);
            push @buffer, [ $type, $tag, [$raw, $delims] ];
        } elsif ($type eq '/') {
            # End Section Tag - Short circuits a recursive call to #parse,
            # caches the buffer for the raw section template, and returns the
            # raw section template and the index immediately following the tag.
            my $msg;
            if (!$section) {
                $msg = "End Section tag '$tag' found, but not in a section!";
            } elsif ($tag ne $section) {
                $msg = "End Section tag closes '$tag'; expected '$section'!";
            }
            $error->($msg, $pos) if $msg;

            my $raw_section = substr($tmpl, $start, $eoc + 1 - $start);
            $cache->{$raw_section} = [@buffer];
            return ($raw_section, $pos);
        } else {
            $error->("Unknown tag type -- $type", $pos);
        }

        # Update our match pointer to coincide with any changes we've made.
        pos($tmpl) = $pos
    }

    # Buffer any remaining template, cache the template for later, and return
    # a reference to the buffer.
    push @buffer, substr($tmpl, $pos);
    $cache->{$tmpl} = [@buffer];
    return \@buffer;
}

# Produces an expanded version of the template represented by the given parse
# tree.
# @param [Array<String,Array>] $parse_tree The AST of a Mustache template.
# @param [Code] $partials A subroutine that looks up partials by name.
# @param [(Any)] @context The context stack to perform key lookups against.
# @return [String] The fully rendered template.
# @api private
sub generate {
    my ($parse_tree, $partials, @context) = @_;

    # Build a helper function to abstract away subtemplate expansion.
    # Recursively calls generate after parsing the given template.  This allows
    # us to use the call stack as our context stack.
    my $build = sub { generate(parse(@_[0,1]), $partials, $_[2], @context) };

    # Walk through the parse tree, handling each element in turn.
    join '', map {
        # If the given element is a string, treat it literally.
        my @result = ref $_ ? () : $_;

        # Otherwise, it's a three element array, containing a tag's type, name,
        # and accessory data.  As a precautionary step, we can prefetch any
        # data value from the context stack (which will be useful in every case
        # except partial tags).
        unless (@result) {
            my ($type, $tag, $data) = @$_;
            my $render = sub { $build->(shift, $data->[1]) };

            my ($ctx, $value) = lookup($tag, @context) unless $type eq '>';

            if ($type eq '{' || $type eq '&' || $type eq '') {
                # Interpolation Tags
                # If the value is a code reference, we should treat it
                # according to Mustache's lambda rules.  Specifically, we
                # should call the sub (passing a "render" function as a
                # convenience), render its contents against the current
                # context, and cache the value (if possible).
                if (ref $value eq 'CODE') {
                    $value = $build->($value->($render));
                    $ctx->{$tag} = $value if ref $ctx eq 'HASH';
                }
                # An empty `$type` represents an HTML escaped tag.
                $value = CGI::escapeHTML($value) unless $type;
                @result = $value;
            } elsif ($type eq '#') {
                # Section Tags
                # `$data` will contain an array reference with the raw template
                # string, and the delimiter pair being used when the section
                # tag was encountered.
                # There are four special cases for section tags.
                #  * If the value is falsey, the section is skipped over.
                #  * If the value is an array reference, the section is
                #    rendered once using each element of the array.
                #  * If the value is a code reference, the raw section string
                #    and a rendering function are passed to the sub; the return
                #    value is then automatically rendered.
                #  * Otherwise, the section is rendered using given value.
                if (ref $value eq 'ARRAY') {
                    @result = map { $build->(@$data, $_) } @$value;
                } elsif ($value) {
                    my @x = @$data;
                    $x[0] = $value->($x[0], $render) if ref $value eq 'CODE';
                    @result = $build->(@x, $value);
                }
            } elsif ($type eq '^') {
                # Inverse Section Tags
                # These should only be rendered if the value is falsey or an
                # empty array reference.  `$data` is as for Section Tags.
                $value = @$value if ref $value eq 'ARRAY';
                @result = $build->(@$data) unless $value;
            } elsif ($type eq '>') {
                # Partial Tags
                # `$data` contains indentation to be applied to the partial.
                # The partial template is looked up thanks to the `$partials`
                # code reference, rendered, and non-empty lines are indented.
                my $partial = scalar $partials->($tag);
                $partial =~ s/^(?=.)/${data}/gm if $data;
                @result = $build->($partial);
            }
        }
        @result; # Collect the results...
    } @$parse_tree;
}

# Performs a lookup of a `$field` in a context stack.
# @param [String] $field The field to lookup.
# @param [(Any)] @context The context stack.
# @return [(Any, Any)] The context element and value for the given `$field`.
# @api private
sub lookup {
    my ($name, @stack) = @_;
    return pop(@stack) if $name eq '.';
    my @names = split(/\./, $name);

    my $lastIndex =scalar(@names) - 1;
    my $target = pop(@names);
    my @localstack;

    my $i = scalar(@stack);
    my ($context, $value);

    while($i){
      my @localStack = @stack;
      $context = $stack[--$i];

      for(@names){
        $context = exists $context->{$_}? $context->{$_} : undef;
        last unless $context;
      }

      if($context){
        if(ref $context eq 'HASH' && exists($context->{$target})){
          $value = $context->{$target};
          last;
        }elsif($context->can($target)){
          $value = $context->$target();
          last;
        }
      }
    }
    return ($context, $value);
}

use namespace::clean;

# Standard hash constructor.
# @param %args Initialization data.
# @return [Template::Mustache] A new instance.
sub new {
    my ($class, %args) = @_;
    return bless({ %args }, $class);
}

our $template_path = '.';

# Filesystem path for template and partial lookups.
# @return [String] +$Template::Mustache::template_path+ (defaults to '.').
# @scope dual
sub template_path { $Template::Mustache::template_path }

our $template_extension = 'mustache';

# File extension for templates and partials.
# @return [String] +$Template::Mustache::template_extension+ (defaults to
#   'mustache').
# @scope dual
sub template_extension { $Template::Mustache::template_extension }

# Package namespace to ignore during template lookups.
#
# As an example, if you subclass +Template::Mustache+ as the class
# +My::Heavily::Namepaced::Views::SomeView+, calls to {render} will
# automatically try to load the template
# +./My/Heavily/Namespaced/Views/SomeView.mustache+ under the {template_path}.
# Since views will very frequently all live in a common namespace, you can
# override this method in your subclass, and save yourself some headaches.
#
#    Setting template_namespace to:      yields template name:
#      My::Heavily::Namespaced::Views => SomeView.mustache
#      My::Heavily::Namespaced        => Views/SomeView.mustache
#      Heavily::Namespaced            => My/Heavily/Namespaced/Views/SomeView.mustache
#
# As noted by the last example, namespaces will only be removed from the
# beginning of the package name.
# @return [String] The empty string.
# @scope dual
sub template_namespace { '' }

our $template_file;

# The template filename to read.  The filename follows standard Perl module
# lookup practices (e.g. My::Module becomes My/Module.pm) with the following
# differences:
# * Templates have the extension given by {template_extension} ('mustache' by
#   default).
# * Templates will have {template_namespace} removed, if it appears at the
#   beginning of the package name.
# * Template filename resolution will short circuit if
#   +$Template::Mustache::template_file+ is set.
# * Template filename resolution may be overriden in subclasses.
# * Template files will be resolved against {template_path}, not +$PERL5LIB+.
# @return [String] The path to the template file, relative to {template_path}.
# @see template
sub template_file {
    my ($receiver) = @_;
    return $Template::Mustache::template_file
        if $Template::Mustache::template_file;

    my $class = ref $receiver || $receiver;
    $class =~ s/^@{[$receiver->template_namespace()]}:://;
    my $ext  = $receiver->template_extension();
    return File::Spec->catfile(split(/::/, "${class}.${ext}"));
};

# Reads the template off disk.
# @return [String] The contents of the {template_file} under {template_path}.
sub template {
    my ($receiver) = @_;
    my $path = $receiver->template_path();
    my $template_file = $receiver->template_file();
    return read_file(File::Spec->catfile($path, $template_file));
}

# Reads a named partial off disk.
# @param [String] $name The name of the partial to lookup.
# @return [String] The contents of the partial (in {template_path}, of type
#   {template_extension}), or the empty string, if the partial does not exist.
sub partial {
    my ($receiver, $name) = @_;
    my $path = $receiver->template_path();
    my $ext  = $receiver->template_extension();
    return read_file(File::Spec->catfile($path, "${name}.${ext}"));
}

# @overload render()
#   Renders a class or instance's template with data from the receiver.  The
#   template will be retrieved by calling the {template} method.  Partials
#   will be fetched by {partial}.
#   @return [String] The fully rendered template.
# @overload render($tmpl)
#   Renders the given template with data from the receiver.  Partials will be
#   fetched by {partial}.
#   @param [String] $tmpl The template to render.
#   @return [String] The fully rendered template.
# @overload render($data)
#   Renders a class or instance's template with data from the receiver.  The
#   template will be retrieved by calling the {template} method.  Partials
#   will be fetched by {partial}.
#   @param [Hash,Object] $data Data to be interpolated into the template.
#   @return [String] The fully rendered template.
# @overload render($tmpl, $data)
#   Renders the given template with the given data.  Partials will be fetched
#   by {partial}.
#   @param [String] $tmpl The template to render.
#   @param [Hash,Class,Object] $data Data to be interpolated into the template.
#   @return [String] The fully rendered template.
# @overload render($tmpl, $data, $partials)
#   Renders the given template with the given data.  Partials will be looked up
#   by calling the given code reference with the partial's name.
#   @param [String] $tmpl The template to render.
#   @param [Hash,Class,Object] $data Data to be interpolated into the template.
#   @param [Code] $partials A function used to lookup partials.
#   @return [String] The fully rendered template.
# @overload render($tmpl, $data, $partials)
#   Renders the given template with the given data.  Partials will be looked up
#   by calling the partial's name as a method on the given class or object.
#   @param [String] $tmpl The template to render.
#   @param [Hash,Class,Object] $data Data to be interpolated into the template.
#   @param [Class,Object] $partials A thing that responds to partial names.
#   @return [String] The fully rendered template.
# @overload render($tmpl, $data, $partials)
#   Renders the given template with the given data.  Partials will be looked up
#   in the given hash.
#   @param [String] $tmpl The template to render.
#   @param [Hash,Class,Object] $data Data to be interpolated into the template.
#   @param [Hash] $partials A hash containing partials.
#   @return [String] The fully rendered template.
sub render {
    my ($receiver, $tmpl, $data, $partials) = @_;
    ($data, $tmpl) = ($tmpl, $data) if !(ref $data) && (ref $tmpl);

    $tmpl       = $receiver->template() unless defined $tmpl;
    $data     ||= $receiver;
    $partials ||= sub {
        unshift @_, $receiver;
        goto &{$receiver->can('partial')};
    };

    my $part = $partials;
    $part = sub { lookup(shift, $partials) } unless ref $partials eq 'CODE';

    my $parsed = parse($tmpl);
    return generate($parsed, $part, $data);
}

1;
