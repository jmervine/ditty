module Sinatra
  module SinatraAuthentication
    app.get "/login" do
      if session[:user]
        redirection = (session[:return_to] ? session[:return_to] : "/")
        redirect redirection
      else
        send options.template_engine, get_view_as_string("login.#{options.template_engine}"), :layout => use_layout?
      end
    end
  end
end
