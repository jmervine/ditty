$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
# load gems
require 'rubygems'
require 'sinatra'
require 'yaml'
require 'pp'
require 'haml'
# load app libs
require 'ditty'
require 'helpers'

# auth
require 'sinbook'
require "sinatra-authentication"

class DittyApp < Sinatra::Application

  configure :development do
    enable :dump_errors, :show_exceptions
    set :logging, Logger::DEBUG
  end

  configure do

    enable :logging, :raise_errors
    set :pass_errors, false

    set :environment, ENV['RACK_ENV']||"production"
    @configuration = Helper::Configure.new(settings.environment, settings.root)
    #set :config, Helper::Configure.new(settings.environment, settings.root)

    set :title,            @configuration.title
    set :timezone,         @configuration.timezone
    set :hostname,         @configuration.hostname
    set :google_analytics, @configuration.google_analytics
    set :share_this,       @configuration.share_this
    set :contact,          @configuration.contact

    set :facebook_id,      @configuration.facebook_id
    set :facebook_key,     @configuration.facebook_key

    #set :config, @configuration

    #settings.config.title

    #unless settings.facebook_id.nil? || settings.facebook_key.nil?
      #facebook do
        #secret settings.facebook_key
        #app_id settings.facebook_id
      #end
    #end

    set :database,         @configuration.database

    set :username,         @configuration.username
    set :password,         @configuration.password

    Mongoid.configure do |config|
      config.master = Mongo::Connection.new.db(settings.database['name'])
      if settings.database['username'] and settings.database['password']
        config.database.authenticate(settings.database['username'], settings.database['password'])
      end
    end
  end

  configure :production do
    set :haml, :ugly => true
  end

  helpers do
    include Helper::Templates
    include Helper::Application
    def kill_cache
      $markup = nil
      $tags = nil
      $archive = nil
      $latest = nil
    end
  end

  before do
    unless request.path_info == "/login" || request.path_info == "/logout"
      session[:return_to] = request.path_info
    end

    unless request.path_info =~ /edit/ or request.path_info =~ /delete/ or request.path_info =~ /preview/ or request.post?
      cache_control :public, :must_revalidate, :max_age => 60
    end

    if request.post?
      kill_cache
    end
  end

  before :method => "post" do
  end

  get "/sitemap.xml" do
    haml :sitemap, :layout => false
  end

  #get "/login" do
    #login_required
    #redirect "/"
  #end

  # sinatra-authentication monkey patch
  get '/logout' do
    session[:user] = nil
    if Rack.const_defined?('Flash')
      flash[:notice] = "Logout successful."
    end
    return_to = ( session[:return_to] ? session[:return_to] : "/" )
    redirect return_to
  end

  get "/post/?" do
    login_required
    haml :form_post, :locals => { :navigation => :_nav_help, :post => Post.new, :state => :new }
  end

  get "/:year/:month/:day/:title_path/?" do
    title_path = "/" + File.join(params['captures'])
    haml choose_template(:post), :layout => choose_layout, :locals => { :post => Post.where(:title_path => title_path).first, :state => :show }
  end

  get "/post/:id/edit/?" do
    login_required
    haml :form_post, :locals => { :post => Post.find(params[:id]), :navigation => :_nav_help, :state => :edit }
  end

  post "/comment/?" do
    login_required
    post = Post.find( params[:comment]['post_id'] )
    post.comments.create( :comment => params[:comment]['comment'], :mongoid_user_id => current_user.id )
    redirect post.title_path
  end

  get "/comment/:comment_id/delete" do
    login_required
    Comment.find( params[:comment_id] ).first.destroy 
    redirect session[:return_to]
  end

  post "/post/?" do
    login_required
    p, t = seperate_post_tags( params[:post] )
    post = Post.create(p)
    t.each do |tag|
      post.associate_or_create_tag(tag)
    end
    post.save!
    redirect post.title_path
  end

  post "/post/preview" do
    login_required
    haml :preview, :locals => { :post => params[:post], :navigation => :_nav_help, :state => :preview }
  end

  post "/post/:id/preview" do
    login_required
    haml :preview, :locals => { :post => params[:post], :navigation => :_nav_help, :post_id => params[:id], :state => :preview }
  end

  post "/post/:id" do
    login_required
    p_post, p_tags = seperate_post_tags( params[:post] )
    post = Post.find( params[:id] )

    post.tags = []
    unless p_tags.empty?
      p_tags.each do |tag|
        post.associate_or_create_tag(tag)
      end
    end
    p_post.each { |key, val| post[key.to_sym] = val }
    post.save!
    redirect post.title_path
  end

  get "/post/:id/delete" do
    login_required
    Post.find( params[:id] ).destroy
    redirect "/"
  end

  get "/tag/:tag" do
    posts = get_posts_from_tag( params[:tag] )
    #redirect "/tag" if posts.empty?
    haml :tag, :layout => choose_layout, :locals => { :latest => posts, :tag => params[:tag], :state => :tag }
  end

  get "/tag" do
    haml choose_template(:tags), 
          :layout => choose_layout, 
          :locals => { 
            :tags => tags_sorted_by_count.reverse, 
            :state => ( is_mobile? ? :show : :index )
          }
  end

  get "/archive/?*" do
    items = archive_items
    haml :archive, :layout => choose_layout, :locals => { :state => :archive }
  end

  get "/:year/?" do
    pass unless params[:year] =~ /[0-9]{4}/
    pass unless !archive_items[params[:year].to_i].empty?

    haml :archive, :layout => choose_layout, :locals => { :archives => { params[:year].to_i => archive_items[params[:year].to_i] } }
  end

  get "/:year/:month/?" do
    pass unless params[:year] =~ /[0-9]{4}/
    pass unless params[:month] =~ /[0-9]{2}/

    posts = Post.all.desc(:created_at).select { |p| p.created_at.year.to_i == params[:year].to_i and p.created_at.month.to_i == params[:month].to_i }

    pass if posts.empty?
    haml choose_template(:index), :layout => choose_layout, :locals => { :latest => posts }
  end

  get "/:year/:month/:day/?" do
    pass unless params[:year] =~ /[0-9]{4}/
    pass unless params[:month] =~ /[0-9]{2}/
    pass unless params[:day] =~ /[0-9]{2}/

    posts = Post.all.desc(:created_at).select { |p| p.created_at.year.to_i == params[:year].to_i and p.created_at.month.to_i == params[:month].to_i and p.created_at.day.to_i == params[:day].to_i }
    pass if posts.empty?
    haml choose_template(:index), :layout => choose_layout, :locals => { :latest => posts }
  end

  get "/" do 
    haml :index, :layout => choose_layout
  end

  not_found do
    redirect "/"
  end

end

