#!/usr/bin/env ruby

puts "Loading Core..." if ENV["trace_flag"]
# Load modules() and module_load methods
require "#{ENV["modules_path"]}/ruby/modules/dsl.rb"
require "#{ENV["modules_path"]}/ruby/modules/initialize.rb"

puts "Loading modules..." if ENV["trace_flag"]
modules %w(trace logging time variables environment filesystem extensions)

# Now load extension module code.
extension_module_load "dsl", "initialize", "cli"

