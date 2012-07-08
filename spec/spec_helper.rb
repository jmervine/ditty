require 'simplecov'
SimpleCov.start do
  filters = %w( cache config doc log public scripts spec store vendor )
  filters.each do |f|
    add_filter "/#{f}/"
  end
end

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
CONFIG = YAML.load_file(File.join(settings.root, "config", "ditty.yml"))[ENV['RACK_ENV']]

# with mongo
def build_clean_data
  database = CONFIG['database']
  Mongoid.configure do |config|
    config.master = Mongo::Connection.new.db(database['name'])
    if database['username'] and database['password']
      config.database.authenticate(database['username'], database['password'])
    end
  end
  Post.destroy_all
  Tag.destroy_all
  tags = %w( tag_one tag_two tag_three tag_four tag_five foo bar baz boo blah )
  (2011..2012).each do |year|
    (5..10).each do |month|
      (5..10).each do |day|
        time = Time.new(year, month, day, 12)
        post = Post.create( :created_at  => time, 
                         :updated_at  => time, 
                         :title       => "post title - #{year}.#{month}.#{day}",
                         :body        => "post body - #{year}.#{month}.#{day}" )
        post.associate_or_create_tag(tags[Random.rand(10)])
        post.associate_or_create_tag(tags[Random.rand(10)])
        post.associate_or_create_tag(tags[Random.rand(10)])
        post.associate_or_create_tag(tags[Random.rand(10)])
        post.associate_or_create_tag(tags[Random.rand(10)])
      end
    end
  end
  #puts " - Post.count is now: #{Post.count}"
  #puts " - Tag.count is now: #{Tag.count}"
end

class TestHelpersTemplates
  include Helper::Templates
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

  # monkey patch for settings calls
  def settings
    SettingsStub.new
  end
  class SettingsStub
    def timezone
      "America/Los_Angeles"
    end
  end
end

class TestHelpersApplication
  include Helper::Application
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
    #def environment
      #(ENV['RACK_ENV']||"test").to_sym
    #end
  end
end

def setup_database

end
set :environment, :test
set :config, CONFIG
set :views,  File.join(File.dirname(__FILE__), "..", "views")
#set :store, MongoStore.new(CONFIG['database'])

include Rack::Test::Methods
def app 
  @app || DittyApp.new
end

