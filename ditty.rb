$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
require 'rubygems'
require 'sinatra'
require 'sinatra/directory-helpers'
require 'template-helpers'
require 'yaml'
require 'pp'


class Ditty < Sinatra::Application

  enable :logging, :dump_errors, :raise_errors

  helpers do
    include TemplateHelpers
  end

  set :default_title, begin settings.config["default_title"] rescue "My little Ditty's!" end

  get "/new" do
    begin
      erb :form_post, :locals => { :page_title => "Sing a little Ditty!",
                                    :navigation => :nav_help }
    rescue
      logger.info "error on : #{params.to_s}"
      pass
    end
  end

  get "/post/*" do
    begin
      path = File.join(settings.store, params[:splat].join)
      erb :post, :locals => { :page_title => post_title(path), :path => path }
    rescue Exception => e
      logger.error e
      pass
    end
  end

  get "/edit/*" do
    begin
      erb :form_post, :locals => { :page_title => "Tweak your Ditty!", 
                                    :path => File.join(settings.store, params[:splat].join),
                                    :navigation => :nav_help }
    rescue Exception => e
      logger.error e
      pass
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
      pass
    end
  end

  # catch all others
  get "/?*" do
    erb :index; 
  end


  #post "/post"    { @ditty.save params }
  #post "/edit"    { @ditty.update params }  
  #post "/comment" { @ditty.comment params }

end

