module Ditty
  module Utils

    @@store = nil
    @@exclude = %w{ internals }

    def store
      @@store
    end

    def list_all path=nil
      path = exists?((path.nil? ? store : path))
      return nil unless path
      list = mtime_sort((Dir[ File.join(path, "**") ] + Dir[ File.join(path, "**", "*") ] + Dir[ File.join(path, "**", "*.*") ]).uniq!)
      @@exclude.each do |ex|
        list.reject! { |i| i =~ Regexp.new(ex) }
      end
      empty_list?(list)
    end

    def find_d query=nil
      list = list_all(store).select { |i| File.directory?(i) }
      list.select! { |i| i =~ Regexp.new("\/"+query+"$") } unless query.nil?
      @@exclude.each do |ex|
        list.reject! { |i| i =~ Regexp.new(ex) }
      end
      empty_list?(list)
    end

    def find_f query=nil
      list = list_all(store).select { |i| !File.directory?(i) }
      list.select! { |i| i =~ Regexp.new(query+".*$") } unless query.nil?
      @@exclude.each do |ex|
        list.reject! { |i| i =~ Regexp.new(ex) }
      end
      empty_list?(list)
    end

    def latest limit=5
      mtime_sort(find_f)[0..(limit-1)]
    end

    def list path=nil
      path = exists?((path.nil? ? store : path))
      empty_list?(Dir[ File.join(path, "*") ])
    end

    def mtime_sort list
      list = empty_list?(list)
      (list.sort_by! { |i| File.mtime(exists?(i)) }).sort! { |x,y| y <=> x } unless list.count == 0
    end

    def delete path
      File.delete exists?(path)
    end

    def create_file path, data
      raise StandardError, "File found, it shouldn't have been!" if File.exists?(path)
      FileUtils.mkdir_p(File.dirname(path)) unless File.directory?(File.dirname(path))
      write_file path, data
    end

    def update_file path, data
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
      raise Sinatra::NotFound, File.dirname(path) unless exists?(File.dirname(path))
      file_handle = File.open(path, "w")
      file_handle.puts(data)
      file_handle.close
      path
    end

    def exists? path
      if File.exists?(path)
        return path
      else
        raise Sinatra::NotFound, path
      end
    end
   
    def empty_list? list
      if list.nil? or list.empty?
        raise Sinatra::NotFound, "empty list"
      else
        return list
      end
    end
  end
end
