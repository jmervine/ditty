ENV['RACK_ENV'] = 'test' # needs to be first
puts "Running with RACK_ENV=#{ENV['RACK_ENV']}."
require './dittyapp'

# gems
require 'sinatra'
require 'mongo'
require 'rack/test'
require 'rspec'
require 'pp'

# load configuration
conf = YAML.load_file(File.join(settings.root, "config", "ditty.yml"))
CONFIG = begin conf["default"].merge!(conf["test"]) rescue conf["default"] end

# with mongo
def build_clean_data
  connection = Mongo::Connection.new.db(CONFIG['database']['name'])[CONFIG['database']['table']]
  connection.remove # clean database
  (2011..2012).each do |year|
    (5..10).each do |month|
      (5..10).each do |day|
        time = Time.new(year, month, day, 12)
        connection.insert( { "created_at"  => time, 
                              "updated_at"  => time, 
                              "title"       => "post title - #{year}.#{month}.#{day}",
                              "body"        => "post body - #{year}.#{month}.#{day}" } )
      end
    end
  end
end

class TestHelpersTemplates
  include HelpersTemplates
  #include DittyUtils
  # monkey patch for request.path_info sinatra helper
  class RequestStub
    def path_info and_return=""
      and_return
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

class TestHelpersApplication
  include HelpersApplication
  def settings; SettingsStub.new; end
  def response; {}; end
  def request; RequestStub.new; end
  class RequestStub
    def env; {}; end
  end
  class SettingsStub
    def root; File.join(File.dirname(__FILE__), ".."); end
    def protect; [ "test" ]; end
    def config; { "auth" => { "username" => "test", "password" => "test" } }; end
  end
end

set :environment, :test
set :views, File.join(File.dirname(__FILE__), "..", "views")
set :store, Ditty::MongoStore.new(CONFIG['database']['name'], CONFIG['database']['table'])

include Rack::Test::Methods
def app 
  @app || DittyApp.new
end

