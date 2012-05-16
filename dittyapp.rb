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

  get "/" do 
    erb :index
  end

  get "/new" do
    erb :form_new, :locals => { :navigation => :nav_help, :post => Post.new }
  end

  get "/post/:id" do
    post = begin
             Post.new params[:id]
           rescue
             Post.new(settings.store.find("title" => delinkify_title(params[:id])).first["_id"]) rescue nil
           end
    erb :post, :locals => { :post => post }
  end

  get "/edit/:id" do
    post = begin
             Post.new params[:id]
           rescue
             Post.new(settings.store.find("title" => delinkify_title(params[:id])).first["_id"]) rescue nil
           end
    erb :form_edit, :locals => { :post => post, :navigation => :nav_help }
  end

  get "/archive" do
      erb :archive
  end

  get "/archive/:year" do
    items = archive_items[params[:year].to_i]
    erb :archive, :locals => { :archives => items }
  end

  get "/archive/:year/:month" do
      erb :archive
  end

  post "/save" do
    begin
      file = params["post_path"]
      if params["post_action"] == "update"
        update_file(file, params["post_contents"])
        logger.info "update: #{file}"
      else
        file = File.join(settings.store, Time.now.strftime("%Y/%m"), post_file(params["post_title"]+".md"))
        create_file(file, params["post_contents"])
        logger.info "created: #{file}"
      end
      erb :post, :locals => { :path => file }
    rescue Exception => e
      logger.info "error on : #{params.to_s}"
      pass if settings.pass_errors
    end
  end

  not_found do
    logger.error "requested file wasn't found"
    ename = env['sinatra.error'].name
    emesg = env['sinatra.error'].message
    begin 
      erb :index
    rescue 
      path = File.join(settings.root, "store", "internals", "getting_started.md")
      erb :post, :locals => { :path => path, :error_name => ename, :error_message => emesg }
    else
      path = File.join(settings.root, "store", "internals", "error.md")
      erb :post, :locals => { :path => path, :error_name => ename, :error_message => emesg }
    end
  end


  #error do
    #logger.info "entering error block"
    #ename = env['sinatra.error'].name
    #emesg = env['sinatra.error'].message
    #begin 
      #path = File.join(settings.root, "store", "internals", "getting_started.md")
      #erb :post, :locals => { :path => path, :error_name => ename, :error_message => emesg }
    #rescue 
      #path = File.join(settings.root, "store", "internals", "error.md")
      #erb :post, :locals => { :path => path, :error_name => ename, :error_message => emesg }
    #end
  #end

  # catch all others
  get "/?*" do
    begin 
      path = File.join(settings.root, "store", "internals", "getting_started.md")
      erb :post, :locals => { :path => path }
    rescue 
      path = File.join(settings.root, "store", "internals", "error.md")
      erb :post, :locals => { :path => path }
    end
  end

  #post "/?*" do
    #begin 
      #path = File.join(settings.root, "store", "internals", "getting_started.md")
      #erb :post, :locals => { :path => path }
    #rescue 
      #path = File.join(settings.root, "store", "internals", "error.md")
      #erb :post, :locals => { :path => path }
    #end
  #end

end

