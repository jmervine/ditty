require './ditty'

require 'sinatra'
require 'sinatra/ditty_utils'
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
    %w{ file1.md file2.md file3.md file4.md }.each do |file|
      path = File.join(CONFIG["store"], year, month, file)
      FileUtils.mkdir_p File.dirname(path)
      FileUtils.touch path
      fh = File.open(path, "w")
      fh.puts "Contents for #{file}!\n"
      fh.close # because they were getting stuck open
    end
  end
end

class TestDittyUtils
  include Sinatra::DittyUtils
  include TemplateHelpers
  @@store = CONFIG["store"]
end

class TestTemplateHelpers
  include TemplateHelpers

  # monkey patch for request.path_info sinatra helper
  class RequestStub
    def path_info
      ""
    end
  end

  def request
    RequestStub.new
  end

  # monkey patch to ignore 'markdown' calls
  def markdown p
    p
  end

end

