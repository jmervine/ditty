require './ditty'

require 'sinatra'
require 'rack/test'
require 'rspec'
require 'pp'

set :environment, :test

# load configuration
conf = YAML.load_file(File.join(settings.root, "config", "ditty.yml"))
CONFIG = begin conf["default"].merge!(conf["test"]) rescue conf["default"] end

class TestHelpers
  include Helpers
end

# start fresh
FileUtils.rm_rf CONFIG["store"] if File.directory? CONFIG["store"]

# create test directory tree
%w{ 2011 2012 }.each do |year|
  %w{ 01 03 05 07 09 11 }.each do |month|
    %w{ file1.txt file2.txt file3.txt file4.txt }.each do |file|
      path = File.join(CONFIG["store"], year, month, file)
      FileUtils.mkdir_p File.dirname(path)
      FileUtils.touch path
      File.open(path, "w").puts "Contents for #{file}!"
    end
  end
end

