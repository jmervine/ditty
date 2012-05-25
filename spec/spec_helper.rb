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
  puts " BULDING CLEAN DATA"
  config = CONFIG['database']
  MongoMapper.database = config['name']
  if config['username'] && config['password']
    MongoMapper.database.authenticate(config['username'], config['password'])
  end
  Post.destroy_all
  puts " - Post.count is now: #{Post.count}"
  Tag.destroy_all
  puts " - Tag.count is now: #{Tag.count}"
  tags = %w( tag_one tag_two tag_three tag_four tag_five )
  (2011..2012).each do |year|
    (5..10).each do |month|
      (5..10).each do |day|
        time = Time.new(year, month, day, 12)
        post = Post.create( :created_at  => time, 
                         :updated_at  => time, 
                         :title       => "post title - #{year}.#{month}.#{day}",
                         :body        => "post body - #{year}.#{month}.#{day}" )
        post.add_tag( tags[Random.rand(5)] )
      end
    end
  end
  puts " - Post.count is now: #{Post.count}"
  puts " - Tag.count is now: #{Tag.count}"
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

