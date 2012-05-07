require 'rubygems'
require 'sinatra'
require 'yaml'
require 'pp'
require './lib/helpers'

class Ditty < Sinatra::Application

  conf = YAML.load_file(File.join(settings.root, "config", "ditty.yml"))
  set :config, begin conf["default"].merge!(conf[ENV['RACK_ENV']]) rescue conf["default"] end
  set :store, settings.config["store"]

  helpers do
    include Helpers
  end

  get "/"         do; erb :index; end
  get "/post"     do; erb :new; end
  get "/edit"     do; erb :edit; end
  get "/archive"  do; erb :archive, :locals => { :archive => self.archive }; end

  #post "/post"    { @ditty.save params }
  #post "/edit"    { @ditty.update params }  
  #post "/comment" { @ditty.comment params }

end

