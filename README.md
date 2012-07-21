# S{cripting,ystem,tack} Management (SM) Framework (Core)

SM is a system scripting & management framework together with a domain
specific language API (DSL) for managing software, systems and stacks!

# Goal

SM delivers an extensible scripting framework providing a very robust DSL API.
A primary tenet of SM is that it must handle as much pain as possible, so you don't have to!
With SM's DSL APIs, you can quickly create your own high-quality extensions,
and expose their commands through SM's command line interface (CLI).

# Architecture

SM itself is a scripting framework that enables very rich DSL commands known as
'apis'. SM lets you use the DSL APIs to painlessly write powerful 'extensions',
which are essentially named sets of scripts (directories!). With SM, you'll find
you can install and manage a multitude of extensions - and even entire sets of
extensions - providing unprecedented levels of control and automation
productivity that are unleashed by the creative abilities of SM's energetic
community of extension authors :)

# Installation

The easiest way to install is to use following oneliner:

    curl -L https://get.smf.sh | sh

# Manual

The manual may be downloaded as a PDF. Keep in mind that it is a work in
progress. Suggestions on improving the manual are most welcome.

The latest version of the manual is kept at the following url:

    https://smf.sh/sm-manual.pdf

Anytime updates are made to the manual a new version is pushed to that url.

# Creating Extensions

There are only a few requirements when creating your own SM extensions.
The extension must live in a dedicated directory. Within this directory are
(at least) the subdirectory bin/, containing at least one executable file called 'help'.

Additionally, in the root of the extension directory you must include a text file called VERSION,
with a version number that follows semantic versioning convention (http://semver.org/);
that is, in the format of X.Y.Z, where X,Y and Z are positive integers.

An extension must also have a README file, in which you should explain your
extension's primary purpose, and any special considerations to be kept in mind
when using it.

The contents of the bin directory can be *any* executable file. This means, for
example, that C-compiled binaries, Ruby Scripts, python, lua, etc... may all be
used according to your requirements and preferences.

Of course, the extensions *I* write are generally in bash; but you can bring your
own implements of choice to the SM party ;)

Additionally, if you write your extensions in bash, a nice DSL is automatically loaded for you.
You can read more about the DSL in the online documentation.

  ~Wayne

Wayne E. Seguin
* wayneeseguin@gmail.com
* http://github.com/wayneeseguin
* http://github.com/sm
* http://twitter.com/wayneeseguin
* https://smf.sh/
* https://rvm.io/

# Contributing

Development repositories are found on the SM GitHub organization page:
    https://github.com/sm/
In the spirit of free software, everyone is encouraged to help improve this project.

Ways that you may contribute to the project are by:

* using the latest development and release versions
* reporting bugs in #smf.sh on irc.freenode.net
* suggesting new features in #smf.sh on irc.freenode.net
* writing or editing documentation, which is greatly appreciated
* translating documentation to a new language, I speek tech and poor engrish
* writing extensions
* writing code (no patch is too small: fix typos, add comments, clean up inconsistent whitespace)
* performing code reviews and assisting with refactoring
* resolving issues
* reviewing patches
* donating, xoxo!

# License

All SM Core scripts and extensions themselves are are licensed under
the Apache License v2.0

Copyright (c) 2009-2011 Wayne E. Seguin

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# License Exceptions:

bin/sm-ll, bin/sm-sql, bin/sm-sem are all part of the GNU Parallel project
and are licensed under the GNU GPL v3 which can be read at either LICENSE.gpl3
or on the web at http://www.gnu.org/licenses/gpl.html

