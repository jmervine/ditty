module Sinatra
  module DittyUtils

    @@store = nil
    @@exclude = %w{ internals }
    def self.registered(app)
      conf = YAML.load_file(File.join(settings.root, "config", "ditty.yml"))  
      config = begin conf["default"].merge!(conf[ENV['RACK_ENV']]) rescue conf["default"] end
      app.set :config, config
      app.set :store, config["store"]
      @@store = config["store"]
    end

    def store
      raise StandardError, "store not set!" if @@store.nil?
      @@store
    end

    def list_all path=nil
      path = (path.nil? ? store : path)
      list = mtime_sort((Dir[ File.join(path, "**") ] + Dir[ File.join(path, "**", "*") ] + Dir[ File.join(path, "**", "*.*") ]).uniq!)
      @@exclude.each do |ex|
        list.reject! { |i| i =~ Regexp.new(ex) }
      end
      list
    end

    def find_d query=nil
      list = list_all(store).select { |i| File.directory?(i) }
      list.select! { |i| i =~ Regexp.new("\/"+query+"$") } unless query.nil?
      @@exclude.each do |ex|
        list.reject! { |i| i =~ Regexp.new(ex) }
      end
      return list
    end

    def find_f query=nil
      list = list_all(store).select { |i| !File.directory?(i) }
      list.select! { |i| i =~ Regexp.new(query+".*$") } unless query.nil?
      @@exclude.each do |ex|
        list.reject! { |i| i =~ Regexp.new(ex) }
      end
      return list
    end

    def latest limit=5
      mtime_sort(find_f)[0..(limit-1)]
    end

    def list path=nil
      path = (path.nil? ? store : path)
      Dir[ File.join(path, "*") ]
    end

    def mtime_sort list
      (list.sort_by! { |i| File.mtime(i) }).sort! { |x,y| y <=> x } unless list.count == 0
    end

    def delete path
      File.delete path
    end

    def create_file path, data
      raise StandardError, "File found, it shouldn't have been!" if File.exists?(path)
      FileUtils.mkdir_p(File.dirname(path)) unless File.directory?(File.dirname(path))
      write_file path, data
    end

    def update_file path, data
      raise StandardError, "File not found!" unless File.exists?(path)
      write_file path, data
    end

    def md_path path
      path += ".md" unless path =~ /\.md$/
      path
    end

    def strip_md_path path
      path.gsub(/\.md$/, "")
    end

    private
    def write_file path, data
      file_handle = File.open(path, "w")
      file_handle.puts(data)
      file_handle.close
      path
    end

  end
  register DittyUtils
end
