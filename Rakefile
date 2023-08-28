require_relative "config/config"
require "bundler"
Bundler.require(:default, Config.env)

desc "Open a ruby console with the application loaded"
task :console => :boot do
  require "irb"
  ARGV.clear
  IRB.start
end

task :boot do
  require_relative "config/boot"
end
