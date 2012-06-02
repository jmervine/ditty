$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
# load gems
require 'rubygems'
require 'sinatra'
require 'ditty'
require 'yaml'
require 'pp'
require 'haml'

# load app libs
require 'ditty'
require 'helpers'

class DittyApp < Sinatra::Application
  #include Ditty

  configure do
    enable :logging, :raise_errors#, :dump_errors

    set :pass_errors, false
    set :environment, ENV['RACK_ENV']||"development"
    set :config,      HelpersApplication.configure!( settings.environment )
    set :title,       HelpersApplication.app_title( settings.config )

    set :timezone, settings.config['timezone']||"America/Los_Angeles"
    # for available zones see http://tzinfo.rubyforge.org/doc/

    # TODO: move to helper
    hostname = settings.config['hostname']||'localhost'
    hostname = "http://"<<hostname unless hostname =~ /^http:\/\//
    set :hostname, hostname
    set :google_analytics, settings.config['google_analytics']||nil

    HelpersApplication.database!( settings.config['database'] )
  end

  configure :production do
    set :haml, :ugly => true
  end

  helpers do
    include HelpersTemplates
    include HelpersApplication

    def choose_layout
      return :mobile if is_mobile?
      return :layout
    end

    def choose_template template
      return "mobile_#{template.to_s}".to_sym if is_mobile?
      return template
    end

    def is_mobile?
      return true if request.env['X_MOBILE_DEVICE']
      return false
    end
  end

  get "/sitemap.xml" do
    haml :sitemap, :layout => false
  end

  get "/m" do
    haml :mobile_index, :layout => :mobile
  end

  get "/m/:year/:month/:day/:title_path/?" do
    title_path = "/" + File.join(params['captures'])
    logger.info title_path
    haml :mobile_post, :layout => :mobile, :locals => { :post => Post.first(:title_path => title_path), :state => :show }
  end

  get "/login" do
    protected!
    redirect "/"
  end

  get "/post/?" do
    protected!
    haml :form_post, :locals => { :navigation => :_nav_help, :post => Post.new, :state => :new }
  end

  get "/:year/:month/:day/:title_path/?" do
    title_path = "/" + File.join(params['captures'])
    logger.info title_path
    haml choose_template(:post), :layout => choose_layout, :locals => { :post => Post.first(:title_path => title_path), :state => :show }
  end

  get "/post/:id/edit/?" do
    protected!
    haml :form_post, :locals => { :post => Post.find(params[:id]), :navigation => :_nav_help, :state => :edit }
  end

  post "/post/?" do
    protected!
    if params[:post]["tags"]
      tags = params[:post]["tags"].split(",").map { |t| t.strip.downcase } unless params[:post]["tags"].blank?
      params[:post].delete("tags")
    end
    post = Post.create(params[:post])
    post.add_tags(tags) if tags
    redirect post.title_path
  end

  post "/post/preview" do
    protected!
    haml :preview, :locals => { :post => params[:post], :navigation => :_nav_help, :state => :preview }
  end

  post "/post/:id/preview" do
    protected!
    haml :preview, :locals => { :post => params[:post], :navigation => :_nav_help, :post_id => params[:id], :state => :preview }
  end

  post "/post/:id" do
    protected!
    # TODO: move to helper or model
    if params[:post]["tags"]
      tags = params[:post]["tags"].split(", ").map { |t| t.strip.downcase } unless params[:post]["tags"].blank?
      params[:post].delete("tags")
    end

    post = Post.find params[:id]
    post.tag_ids.reject! { |t| !tags.include? t }

    params[:post].each do |key, val|
      post[key.to_sym] = val
    end

    if tags
      post.add_tags(tags)
    else
      post.save!
    end
    redirect post.title_path
  end

  get "/post/:id/delete" do
    protected!
    Post.destroy params[:id]
    redirect "/"
  end

  get "/tag" do
    haml choose_template(:tags), :layout => choose_layout, :locals => { :tags => (Tag.all.sort_by { |t| t.posts.count }).reverse, :state => ( is_mobile? ? :show : :index ) }
  end

  get "/tag/:tag" do
    posts = Tag.where(:name => params[:tag]).first.posts.reverse
    redirect "/tag" if posts.empty?
    haml :tag, :layout => choose_layout, :locals => { :latest => posts, :tag => params[:tag], :state => :tag }
  end

  get "/archive/?*" do
    items = archive_items
    haml :archive, :layout => choose_layout, :locals => { :state => :archive }
  end

  get "/:year/?" do
    pass unless params[:year] =~ /[0-9]{4}/

    posts = { params[:year].to_i => archive_items[params[:year].to_i] }
    pass if posts.empty?
    haml :archive, :layout => choose_layout, :locals => { :archives => posts }
  end

  get "/:year/:month/?" do
    pass unless params[:year] =~ /[0-9]{4}/
    pass unless params[:month] =~ /[0-9]{2}/

    posts = Post.all(:order => :created_at.desc).select { |p| p.created_at.year.to_i == params[:year].to_i and p.created_at.month.to_i == params[:month].to_i }
    pass if posts.empty?
    haml choose_template(:index), :layout => choose_layout, :locals => { :latest => posts }
  end

  get "/:year/:month/:day/?" do
    pass unless params[:year] =~ /[0-9]{4}/
    pass unless params[:month] =~ /[0-9]{2}/
    pass unless params[:day] =~ /[0-9]{2}/

    posts = Post.all(:order => :created_at.desc).select { |p| p.created_at.year.to_i == params[:year].to_i and p.created_at.month.to_i == params[:month].to_i and p.created_at.day.to_i == params[:day].to_i }
    pass if posts.empty?
    haml choose_template(:index), :layout => choose_layout, :locals => { :latest => posts }
  end

  get "/" do 
    logger.info authorized?
    haml choose_template(:index), :layout => choose_layout
  end

  not_found do
    redirect "/"
  end

end

