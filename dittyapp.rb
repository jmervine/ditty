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

  configure do
    enable :logging, :raise_errors#, :dump_errors

    set :pass_errors, false
    set :environment, ENV['RACK_ENV']||"development"
    set :config,      HelpersApplication.configure!( settings.environment )
    set :title,       HelpersApplication.app_title( settings.config )

    HelpersApplication.database!( settings.config['database'] )
  end

  helpers do
    include HelpersTemplates
    include HelpersApplication
    def get_layout
      @layout_default = ( request.env['X_MOBILE_DEVICE'] ? :layout_mobile : :layout )
      if ( request.path_info =~ /force=mobile/ )
        @layout_default = :layout_mobile
      end
      logger.info "layout: #{@layout_default}"
    end
  end

  before do
    get_layout()
  end

  get "/login" do
    protected!
    erb :index, :layout => @layout_default
  end

  get "/post/?" do
    protected!
    erb :_post, :locals => { :navigation => :nav_help, :post => Post.new, :state => :new }
  end

  get "/post/:id/?" do
    erb :post, :locals => { :post => Post.find(params[:id]), :state => :show }
  end

  get "/post/:id/edit/?" do
    protected!
    erb :_post, :locals => { :post => Post.find( params[:id] ), :navigation => :nav_help, :state => :edit }
  end

  post "/post/?" do
    protected!
    erb :post, :locals => { :post => Post.create(params[:post]), :state => :show }
  end

  post "/post/:id" do
    protected!
    post = Post.find params[:id] #params[:post]
    params[:post].each do |key, val|
      post[key.to_sym] = val
    end
    post.save!
    erb :post, :locals => { :post => post, :state => :show }
  end

  get "/post/:id/delete" do
    protected!
    Post.destroy params[:id]
    erb :index
  end

  get "/archive/?" do
    items = archive_items
    erb :archive
  end

  get "/archive/:year/?" do
    items = { params[:year].to_i => archive_items[params[:year].to_i] }
    erb :archive, :locals => { :archives => items }
  end

  get "/archive/:year/:month/?" do
    posts = Post.all(:order => :created_at.desc).select { |p| p.created_at.year.to_i == params[:year].to_i and p.created_at.month.to_i == params[:month].to_i }
    erb :index, :locals => { :latest => posts }
  end

  get "/" do 
    logger.info authorized?
    erb :index, :layout => @layout_default
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

