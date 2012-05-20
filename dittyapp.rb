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

  helpers do
    include HelpersTemplates
    include HelpersApplication
  end

  enable :logging, :raise_errors#, :dump_errors

  set :pass_errors, false
  set :config,      HelpersApplication.configure!
  set :store,       HelpersApplication.database!( settings.config )
  set :title,       HelpersApplication.app_title( settings.config )

  Post.data_store = settings.store

  get "/login" do
    protected!
    erb :index
  end

  get "/post/?" do
    protected!
    erb :_post, :locals => { :navigation => :nav_help, :post => Post.new }
  end

  get "/post/:id/?" do
    post = begin
             Post.load params[:id]
           rescue
             Post.load(settings.store.find("title" => delinkify_title(params[:id])).first) rescue nil
           end
    erb :post, :locals => { :post => post }
  end

  get "/post/:id/edit/?" do
    protected!
    post = begin
             Post.load params[:id]
           rescue
             Post.load(settings.store.find("title" => delinkify_title(params[:id])).first) rescue nil
           end
    erb :_post, :locals => { :post => post, :navigation => :nav_help }
  end

  post "/post" do
    protected!
    post = Post.new(params[:post])
    post.insert
    erb :post, :locals => { :post => post }
  end

  post "/post/:id" do
    protected!
    post = Post.load(params[:id])
    post.merge!(params[:post])
    post.update
    erb :post, :locals => { :post => post }
  end

  get "/post/:id/delete" do
    protected!
    Post.load(params[:id]).remove
    erb :index
  end

  get "/archive/?" do
    items = archive_items
    erb :archive#, :locals => { :archives => items }
  end

  get "/archive/:year/?" do
    items = { params[:year].to_i => archive_items[params[:year].to_i] }
    erb :archive, :locals => { :archives => items }
  end

  get "/archive/:year/:month/?" do
    items = settings.store.find.select { |p| p["created_at"].year.to_i == params[:year].to_i and p["created_at"].month.to_i == params[:month].to_i }
    posts = items.collect { |i| Post.load(i) }
    erb :index, :locals => { :latest => collection_rsort(posts) } 
  end

  get "/" do 
    logger.info authorized?
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

