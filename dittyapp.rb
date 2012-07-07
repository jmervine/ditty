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
require 'diskcached'

class DittyApp < Sinatra::Application

  configure do

    enable :logging, :raise_errors#, :dump_errors
    set :logging, Logger::DEBUG

    set :pass_errors, false

    set :environment, ENV['RACK_ENV']||"production"
    @configuration = Helper::Configure.new(settings.environment, settings.root)

    set :title,            @configuration.title
    set :timezone,         @configuration.timezone
    set :hostname,         @configuration.hostname
    set :google_analytics, @configuration.google_analytics
    set :share_this,       @configuration.share_this
    set :disqus,           @configuration.disqus
    set :contact,          @configuration.contact
    set :database,         @configuration.database

    set :username,         @configuration.username
    set :password,         @configuration.password

    Mongoid.configure do |config|
      config.master = Mongo::Connection.new.db(settings.database['name'])
      if settings.database['username'] and settings.database['password']
        config.database.authenticate(settings.database['username'], settings.database['password'])
      end
    end

    $diskcache = Diskcached.new(File.join(settings.root, 'cache'))
    $diskcache.flush # ensure caches are empty on startup
  end

  configure :production do
    set :haml, :ugly => true
    set :logging, Logger::INFO
  end

  helpers do
    include Helper::Templates
    include Helper::Application
  end

  before do
    logger.debug "DEBUG MODE"
    logger.debug "authorized? = #{authorized?.to_s}"
    @cache_key = cache_sha(request.path_info)
  end

  get "/sitemap.xml" do
    $diskcache.cache('sitemap') do
      haml :sitemap, :layout => false
    end
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
    begin
      raise Diskcached::NotFound if authorized?
      content = $diskcache.get(@cache_key) 
    rescue Diskcached::NotFound
      content = haml( choose_template(:post), :layout => choose_layout, :locals => { :post => Post.where(:title_path => title_path).first, :state => :show } )
      $diskcache.set(@cache_key, content) unless authorized?
    end
    content
  end

  get "/post/:id/edit/?" do
    protected!
    haml :form_post, :locals => { :post => Post.find(params[:id]), :navigation => :_nav_help, :state => :edit }
  end
  post "/post/?" do
    protected!
    $diskcache.flush
    p, t = seperate_post_tags( params[:post] )
    post = Post.create(p)
    t.each do |tag|
      post.associate_or_create_tag(tag)
    end
    post.save!
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
    $diskcache.flush
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
    protected!
    Post.find( params[:id] ).destroy
    redirect "/"
  end

  get "/tag/:tag" do
    begin
      raise Diskcached::NotFound if authorized?
      content = $diskcache.get(@cache_key) 
    rescue Diskcached::NotFound
      posts = get_posts_from_tag( params[:tag] )
      redirect "/tag" if posts.empty?
      content = haml(:tag, :layout => choose_layout, :locals => { :latest => posts, :tag => params[:tag], :state => :tag })
      $diskcache.set(@cache_key, content) unless authorized?
    end
    content
  end

  get "/tag" do
    begin
      raise Diskcached::NotFound if authorized?
      content = $diskcache.get(@cache_key) 
    rescue Diskcached::NotFound
      content = haml choose_template(:tags), 
                    :layout => choose_layout, 
                    :locals => { 
                      :tags => tags_sorted_by_count.reverse, 
                      :state => ( is_mobile? ? :show : :index )
                    }
      $diskcache.set(@cache_key, content) unless authorized?
    end
    content
  end

  get "/archive/?*" do
    begin
      raise Diskcached::NotFound if authorized?
      content = $diskcache.get(@cache_key) 
    rescue Diskcached::NotFound
      content = haml( :archive, :layout => choose_layout, :locals => { :state => :archive } )
      $diskcache.set(@cache_key, content) unless authorized?
    end
    content
  end

  get "/:year/?" do
    pass unless params[:year] =~ /[0-9]{4}/
    pass unless !archive_items[params[:year].to_i].empty?

    begin
      raise Diskcached::NotFound if authorized?
      content = $diskcache.get(@cache_key) 
    rescue Diskcached::NotFound
      content = haml(:archive, :layout => choose_layout, 
                     :locals => { :archives => { params[:year].to_i => archive_items[params[:year].to_i] } })
      $diskcache.set(@cache_key, content) unless authorized?
    end
    content
  end

  get "/:year/:month/?" do
    pass unless params[:year] =~ /[0-9]{4}/
    pass unless params[:month] =~ /[0-9]{2}/

    begin
      raise Diskcached::NotFound if authorized?
      content = $diskcache.get(@cache_key) 
    rescue Diskcached::NotFound
      posts = Post.all.desc(:created_at).select { |p| p.created_at.year.to_i == params[:year].to_i and p.created_at.month.to_i == params[:month].to_i }

      pass if posts.empty?

      content = haml( choose_template(:index), :layout => choose_layout, :locals => { :latest => posts } )
      $diskcache.set(@cache_key, content) unless authorized?
    end
    content
  end

  get "/:year/:month/:day/?" do
    pass unless params[:year] =~ /[0-9]{4}/
    pass unless params[:month] =~ /[0-9]{2}/
    pass unless params[:day] =~ /[0-9]{2}/

    begin
      raise Diskcached::NotFound if authorized?
      content = $diskcache.get(@cache_key) 
    rescue Diskcached::NotFound
      posts = Post.all.desc(:created_at).select { |p| p.created_at.year.to_i == params[:year].to_i and p.created_at.month.to_i == params[:month].to_i and p.created_at.day.to_i == params[:day].to_i }
      pass if posts.empty?
      content = haml(choose_template(:index), :layout => choose_layout, :locals => { :latest => posts })
      $diskcache.set(@cache_key, content) unless authorized?
    end
    content
  end

  get "/" do 
    begin
      raise Diskcached::NotFound if authorized?
      content = $diskcache.get(@cache_key) 
      logger.debug("reading index from cache") unless authorized?
    rescue Diskcached::NotFound
      logger.debug("storing index to cache") unless authorized?
      content = haml(:index, :layout => choose_layout)
      $diskcache.set(@cache_key, content) unless authorized?
    end
    content
  end

  not_found do
    redirect "/"
  end

end

