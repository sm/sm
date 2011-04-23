#!/usr/bin/env ruby

def modules(modules)
  fail "No modules specified to load." if (modules.nil? || modules.empty?)

  modules.to_a.each do |mod|
    puts "Loading Module #{mod}" if ENV["trace_flag"]
    bdsm = "#{ENV["modules_path"]}/ruby/#{mod}"
    extension="#{ENV["extension_modules_path"]}/ruby/#{mod}"

    [bdsm,extension].each do |path|
      %w(dsl initialize).each do |name|
        file="#{path}/#{name}.rb"
        if File.exist?(file) && File.size(file) > 0
          puts "Loading #{file}" if ENV["trace_flag"]
          load file
        end
      end
    end
  end
end

def extension_module_load(*files)
  files.each do |name|
    file = "#{ENV["extension_modules_path"]}/bash/#{name}.rb"
    if File.exist?(file) && File.size(file) > 0
      puts "Loading #{file}" if $trace_flag
      load file
    end
  end
end
