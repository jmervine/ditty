$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
# load gems
require 'rubygems'
require 'sinatra'
require 'yaml'
require 'pp'
require 'haml'
require 'diskcached'
require 'mongoid'
require 'will_paginate'
require 'will_paginate/array'

# load app libs
require 'ditty'
require 'helpers'

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
    Mongoid.identity_map_enabled = true

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
    $diskcache.flush
    Post.find( params[:id] ).destroy
    redirect "/"
  end

  get "/tag/:tag" do
    params[:page] ||= '1'
    @cache_key = cache_sha(request.path_info+params[:page])
    begin
      raise Diskcached::NotFound if authorized?
      content = $diskcache.get(@cache_key) 
    rescue Diskcached::NotFound
      posts = get_posts_from_tag( params[:tag] ).paginate( :page => params[:page], :per_page => 5)
      redirect "/tag" if posts.empty?
      content = haml(:tag, :layout => choose_layout, :locals => { :posts => posts, :tag => params[:tag], :state => :tag })
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

  get "/:year/:month/:day/?" do
    pass unless params[:year] =~ /[0-9]{4}/
    pass unless params[:month] =~ /[0-9]{2}/
    pass unless params[:day] =~ /[0-9]{2}/

    params[:page] ||= '1'
    @cache_key = cache_sha(request.path_info+params[:page])
    begin
      raise Diskcached::NotFound if authorized?
      content = $diskcache.get(@cache_key) 
    rescue Diskcached::NotFound
      # TODO: replace with a mongo map/reduce
      posts = Post.all.desc(:created_at).select do |p| 
                (p.created_at.year.to_i == params[:year].to_i && p.created_at.month.to_i == params[:month].to_i && p.created_at.day.to_i == params[:day].to_i)
              end.paginate( :page => params[:page], :per_page => 5)
      pass if posts.empty?
      content = haml(choose_template(:index), :layout => choose_layout, :locals => { :posts => posts })
      $diskcache.set(@cache_key, content) unless authorized?
    end
    content
  end

  get "/:year/:month/?" do
    pass unless params[:year] =~ /[0-9]{4}/
    pass unless params[:month] =~ /[0-9]{2}/

    params[:page] ||= '1'
    @cache_key = cache_sha(request.path_info+params[:page])
    begin
      raise Diskcached::NotFound if authorized?
      content = $diskcache.get(@cache_key) 
    rescue Diskcached::NotFound
      # TODO: replace with a mongo map/reduce
      posts = Post.all.desc(:created_at).select do |p| 
                (p.created_at.year.to_i == params[:year].to_i && p.created_at.month.to_i == params[:month].to_i )
              end.paginate( :page => params[:page], :per_page => 5)

      pass if posts.empty?

      content = haml( choose_template(:index), :layout => choose_layout, :locals => { :posts => posts } )
      $diskcache.set(@cache_key, content) unless authorized?
    end
    content
  end

  get "/" do 
    params[:page] ||= '1'
    @cache_key = cache_sha('index-'+params[:page])
    begin
      raise Diskcached::NotFound if authorized?
      content = $diskcache.get(@cache_key) 
      logger.debug("reading index from cache -- 'index-#{params[:page]}'") unless authorized?
    rescue Diskcached::NotFound
      logger.debug("storing index to cache -- 'index-#{params[:page]}'") unless authorized?
      posts = Post.all.desc(:created_at).paginate( :page => params[:page], :per_page => 5)
      content = haml(:index, :layout => choose_layout, :locals => { :posts => posts })
      $diskcache.set(@cache_key, content) unless authorized?
    end
    content
  end

  get "/flush_cache" do
    protected!
    "<pre>"+($diskcache.flush).join("\n")+"</pre>"
  end

  not_found do
    redirect "/"
  end

end

