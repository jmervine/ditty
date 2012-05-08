require './ditty'

require 'sinatra'
require 'sinatra/directory-helpers'
require 'rack/test'
require 'rspec'
require 'pp'

ENV['RACK_ENV'] = 'test'

# load configuration
conf = YAML.load_file(File.join(settings.root, "config", "ditty.yml"))
CONFIG = begin conf["default"].merge!(conf["test"]) rescue conf["default"] end

set :environment, :test
set :store, CONFIG["store"]

# start fresh
FileUtils.rm_rf CONFIG["store"] if File.directory? CONFIG["store"]

# create test directory tree
%w{ 2011 2012 }.each do |year|
  %w{ 01 03 05 07 09 11 }.each do |month|
    %w{ file1.txt file2.txt file3.txt file4.txt }.each do |file|
      path = File.join(CONFIG["store"], year, month, file)
      FileUtils.mkdir_p File.dirname(path)
      FileUtils.touch path
      fh = File.open(path, "w")
      fh.puts "Contents for #{file}!\n"
      fh.close
    end
  end
end

class TestDirectoryHelpers
  include Sinatra::DirectoryHelpers
  include TemplateHelpers
  @@store = CONFIG["store"]
end

class TestTemplateHelpers
  include TemplateHelpers
end

#Rspec.configure do |conf|
  #conf.include Rack::Test::Methods
#end

#before do
  #def app
    #Sinatra::Application
  #end
#end
