$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
require 'rubygems'
require 'sinatra'
require 'sinatra/directory-helpers'
require 'template-helpers'
require 'yaml'
require 'pp'


class Ditty < Sinatra::Application

  helpers do
    include TemplateHelpers
  end

  set :default_title, begin settings.config["default_title"] rescue "My little Ditty's!" end

  get "/"         do; erb :index; end
  get "/post"     do; erb :form_post, :locals => { :page_title => "Sing a little Ditty!" }; end
  get "/edit/*"     do; erb :form_post, :locals => { :page_title => "Tweak your Ditty!", :path => File.join(settings.store, params[:splat].join) }; end
  get "/archive/?*" do
    y, m = params[:splat].join.split("/")
    title = "Archive :: "
    if m.nil?
      title << y
    else
      title << "#{months[m.to_i-1].capitalize}, #{y}"
    end
    erb :archive, :locals => { :archive => find_f(File.join(settings.store, params[:splat])),
                               :archive_title => title }
  end

  #post "/post"    { @ditty.save params }
  #post "/edit"    { @ditty.update params }  
  #post "/comment" { @ditty.comment params }

end

