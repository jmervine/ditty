module Helper
  class Configure
    attr_accessor :configuration

    def initialize env, root, file="./config/ditty.yml"
      begin
        configuration = YAML.load_file(File.join(root, file))[env]
      rescue
        raise "Missing configuration for '#{env}'."
      end

      @environment       = env
      @title             = configuration['title']||title
      @hostname          = ensure_hostname_format(configuration['hostname'])||hostname
      @timezone          = configuration['timezone']||timezone
      @google_analytics  = configuration['google_analytics']||google_analytics
      @database          = configuration['database']

      @username          = configuration['auth']['username']
      @password          = configuration['auth']['password']

      database_connection!
    end

    def database
      @database||=nil
    end
    def environment
      @environment||="production"
    end
    def hostname
      @hostname||="http://localhost"
    end
    def timezone
      @timezone||="America/Los_Angeles"
    end
    def google_analytics
      @google_analytics||=nil
    end
    def title
      @title||="Ditty!"
    end
    def app_title config
      begin
        config["title"]
      rescue
        "Ditty!"
      end
    end
    def username
      @username
    end
    def password
      @password
    end

    private
    def database_connection!
      MongoMapper.database = @database['name']
      if database['username'] && @database['password']
        unless MongoMapper.database.authenticate(@database['username'], @database['password'])
          raise "Database Authentication Failed!"
        end
      end
    end

    def ensure_hostname_format host
      return "http://"<<host unless host =~ /^http:\/\//
      return host
    end
  end
end
