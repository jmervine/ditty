$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
require 'rubygems'
require 'sinatra'
require 'sinatra/ditty_utils'
require 'template-helpers'
require 'yaml'
require 'pp'


class Ditty < Sinatra::Application

  enable :logging, :dump_errors, :raise_errors

  set :pass_errors, false

  helpers do
    include TemplateHelpers
  end

  set :title, begin settings.config["title"] rescue "My little Ditty's!" end

  get "/new" do
    begin
      erb :form_post, :locals => { :navigation => :nav_help }
    rescue
      logger.info "error on : #{params.to_s}"
      pass if settings.pass_errors
    end
  end

  get "/post/*" do
    begin
      path = md_path(File.join(settings.store, params[:splat].join))
      erb :post, :locals => { :path => path }
    rescue Exception => e
      logger.error e
      pass if settings.pass_errors
    end
  end

  get "/edit/*" do
    begin
      erb :form_post, :locals => { :path => md_path(File.join(settings.store, params[:splat].join)),
                                    :navigation => :nav_help }
    rescue Exception => e
      logger.error e
      pass if settings.pass_errors
    end
  end

  get "/archive/?*" do
    begin
      y, m = params[:splat].join.split("/")
      title = "Archive :: "
      if m.nil?
        title << y
      else
        title << "#{months[m.to_i-1].capitalize}, #{y}"
      end
      erb :archive, :locals => { :archive => find_f(File.join(settings.store, params[:splat])),
                                 :archive_title => title }
    rescue Exception => e
      logger.error e
      pass if settings.pass_errors
    end
  end

  get "/getting_started" do
    path = File.join(settings.root, "store", "internals", "getting_started.md")
    erb :post, :locals => { :path => path }
  end

  get "/error" do
    path = File.join(settings.root, "store", "internals", "error.md")
    erb :post, :locals => { :path => path }
  end

  # catch all others
  get "/?*" do
    erb :index; 
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
      logger.error e
      pass
    end
  end

  post "/?*" do
    erb :index; 
  end

end

