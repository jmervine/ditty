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

  def configure! env
    begin
      YAML.load_file(File.join(settings.root, "config", "ditty.yml"))[env]
    rescue
      raise "Missing configuration for #{env}."
    end
  end

  def database! config
    MongoMapper.database = config['name']
    if config['username'] && config['password']
      MongoMapper.database.authenticate(config['username'], config['password'])
    else
      true
    end
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

  def add_tags tag_string, post
    tags = tag_string.split(",").split(" ").compact
    tags.each do |tag|
      if t = Ditty::Tag.where(:tag => tag).first
        return t.add_tag(post.id).save! unless t.has_id?(post.id)
      else
        return Ditty::Tag.new(:tag => tag).add_tag(post.id).save!
      end
    end
  end

end
