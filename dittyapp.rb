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

class DittyApp < Sinatra::Application

  configure do

    enable :logging, :raise_errors#, :dump_errors
    set :pass_errors, false

    set :environment, ENV['RACK_ENV']||"production"
    @configuration = Helper::Configure.new(settings.environment, settings.root)

    set :title,            @configuration.title
    set :timezone,         @configuration.timezone
    set :hostname,         @configuration.hostname
    set :google_analytics, @configuration.google_analytics

    set :username,         @configuration.username
    set :password,         @configuration.password
  end

  configure :production do
    set :haml, :ugly => true
  end

  helpers do
    include Helper::Templates
    include Helper::Application
  end

  get "/sitemap.xml" do
    haml :sitemap, :layout => false
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
    haml choose_template(:post), :layout => choose_layout, :locals => { :post => Post.first(:title_path => title_path), :state => :show }
  end

  get "/post/:id/edit/?" do
    protected!
    haml :form_post, :locals => { :post => Post.find(params[:id]), :navigation => :_nav_help, :state => :edit }
  end

  post "/post/?" do
    protected!
    p, t = seperate_post_tags( params[:post] )
    post = Post.create(p)
    post.add_tags(t) unless t.empty?
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
    p_post, p_tags = seperate_post_tags( params[:post] )
    post = Post.find( params[:id] )

    post.tag_ids.reject! { |t| !p_tags.include? t }

    p_post.each { |key, val| post[key.to_sym] = val }

    if p_tags.empty?
      post.save!
    else
      post.add_tags(p_tags)
    end
    redirect post.title_path
  end

  get "/post/:id/delete" do
    protected!
    Post.destroy params[:id]
    redirect "/"
  end

  get "/tag/:tag" do
    posts = get_posts_from_tag( params[:tag] )
    redirect "/tag" if posts.empty?
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
    haml :index
  end

  not_found do
    redirect "/"
  end

end

