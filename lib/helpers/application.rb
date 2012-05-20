module HelpersApplication
  extend self
  def protected!
    unless authorized? 
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  #TODO: replace with session based auth for logout
  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [username, password]
  end

  def configure!
    yaml = YAML.load_file(File.join(settings.root, "config", "ditty.yml"))  
    begin 
      return yaml["default"].merge!(yaml[ENV['RACK_ENV']]) 
    rescue 
      return yaml["default"] 
    end
  end

  def database! config
    Ditty::MongoStore.new(config['database']['name'], config['database']['table'])
  end

  def app_title config
    begin
      config["title"]
    rescue
      "Ditty!"
    end
  end

  def username
    settings.config["auth"]["username"]
  end

  def password
    settings.config["auth"]["password"]
  end

end
