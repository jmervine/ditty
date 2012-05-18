$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
# load gems
require 'rubygems'
require 'sinatra'
require 'ditty'
require 'yaml'
require 'pp'

# load app libs
require 'ditty'
require 'helpers'

class DittyApp < Sinatra::Application
  include Ditty

  enable :logging, :raise_errors#, :dump_errors

  set :pass_errors, false

  conf = YAML.load_file(File.join(root, "config", "ditty.yml"))  
  set :config, begin conf["default"].merge!(conf[ENV['RACK_ENV']]) rescue conf["default"] end
  set :store, MongoStore.new(settings.config['database'], settings.config['table'])
  set :title, begin settings.config["title"] rescue "My little Ditty's!" end

  Post.data_store = settings.store

  helpers do
    include HelpersTemplates
    #include DittyUtils
    #@@store = settings.store
  end

  get "/post" do
    erb :_post, :locals => { :navigation => :nav_help, :post => Post.new }
  end

  get "/post/:id" do
    post = begin
             Post.load params[:id]
           rescue
             Post.load(settings.store.find("title" => delinkify_title(params[:id])).first) rescue nil
           end
    erb :post, :locals => { :post => post }
  end

  get "/post/:id/edit" do
    post = begin
             Post.load params[:id]
           rescue
             Post.load(settings.store.find("title" => delinkify_title(params[:id])).first) rescue nil
           end
    erb :_post, :locals => { :post => post, :navigation => :nav_help }
  end

  post "/post" do
    post = Post.new(params[:post])
    post.insert
    erb :post, :locals => { :post => post }
  end

  post "/post/:id" do
    post = Post.load(params[:id])
    post.merge!(params[:post])
    post.update
    erb :post, :locals => { :post => post }
  end

  delete "/post/:id" do
    Post.load(params[:id]).remove
    erb :index
  end

  get "/archive" do
      erb :archive
  end

  get "/archive/:year" do
    items = archive_items[params[:year].to_i]
    erb :archive, :locals => { :archives => items }
  end

  get "/archive/:year/:month" do
    #archive_items[params[:year].to_i].include?(params[:month].to_i)
    items = settings.store.find.select { |p| p["created_at"].year.to_i == params[:year].to_i and p["created_at"].month.to_i == params[:month].to_i }
    posts = items.collect { |i| Post.load(i) }
    erb :index, :locals => { :latest => posts } # little hack to not duplicate code
  end

  get "/" do 
    erb :index
  end

  not_found do
    begin 
      erb :index
    rescue 
      erb "Action couldn't be completed!"
    end
  end

  error do
    logger.info "entering error block"
    ename = env['sinatra.error'].name
    emesg = env['sinatra.error'].message
    begin 
      path = File.join(settings.root, "store", "internals", "getting_started.md")
      erb :post, :locals => { :path => path, :error_name => ename, :error_message => emesg }
    rescue 
      path = File.join(settings.root, "store", "internals", "error.md")
      erb :post, :locals => { :path => path, :error_name => ename, :error_message => emesg }
    end
  end

  # catch all others
end

