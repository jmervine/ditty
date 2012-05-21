ENV['RACK_ENV'] ||= 'test' # needs to be first
puts "Running with RACK_ENV=#{ENV['RACK_ENV']}."

require './dittyapp'
require './lib/ditty'
require './lib/helpers'

# gems
require 'sinatra'
require 'mongo'
require 'rack/test'
require 'rspec'
require 'pp'

# load configuration
conf = YAML.load_file(File.join(settings.root, "config", "ditty.yml"))
CONFIG = begin conf["default"].merge!(conf[ENV['RACK_ENV']]) rescue conf["default"] end

# with mongo
def build_clean_data
  config = CONFIG['database']
  MongoMapper.database = config['name']
  if config['username'] && config['password']
    MongoMapper.database.authenticate(config['username'], config['password'])
  end
  Ditty::Post.destroy_all
  (2011..2012).each do |year|
    (5..10).each do |month|
      (5..10).each do |day|
        time = Time.new(year, month, day, 12)
        Ditty::Post.new( :created_at  => time, 
                         :updated_at  => time, 
                         :title       => "post title - #{year}.#{month}.#{day}",
                         :body        => "post body - #{year}.#{month}.#{day}" ).save!
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

def setup_database

end
set :environment, :test
set :config, CONFIG
set :views,  File.join(File.dirname(__FILE__), "..", "views")
#set :store, Ditty::MongoStore.new(CONFIG['database'])

include Rack::Test::Methods
def app 
  @app || DittyApp.new
end

