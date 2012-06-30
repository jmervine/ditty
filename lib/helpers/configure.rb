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
      @title             = configuration['title'] rescue title
      @hostname          = ensure_hostname_format(configuration['hostname']) rescue hostname
      @timezone          = configuration['timezone'] rescue timezone
      @google_analytics  = configuration['google_analytics'] rescue google_analytics
      @share_this        = configuration['share_this'] rescue share_this
      @contact           = configuration['contact'] rescue contact
      @facebook_key      = configuration['facebook_key'] rescue facebook_key
      @facebook_id       = configuration['facebook_id'] rescue facebook_id

      @database          = configuration['database'] rescue nil

      @username          = configuration['auth']['username'] rescue nil
      @password          = configuration['auth']['password'] rescue nil

      #database_connection!
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
    def share_this
      @share_this||=nil
    end
    def contact
      @contact||=nil
    end
    def facebook_key
      @facebook_key||=nil
    end
    def facebook_id
      @facebook_id||=nil
    end
    def title
      @title||="Ditty!"
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
