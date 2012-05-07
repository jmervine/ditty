module Helpers

  def store
    raise StandardError, "store not set!" if @store.nil?
    @store
  end

  def store=(s)
    @store = s
  end

  def list_all path=store
    mtime_sort((Dir[ File.join(path, "**") ] + Dir[ File.join(path, "**", "*") ] + Dir[ File.join(path, "**", "*.*") ]).uniq!)
  end

  def find_d query=nil
    list = list_all(store).select { |i| File.directory?(i) }
    list.select! { |i| i =~ Regexp.new("\/"+query+"$") } unless query.nil?
    return list
  end

  def find_f query=nil
    list = list_all(store).select { |i| !File.directory?(i) }
    list.select! { |i| i =~ Regexp.new(query+".*$") } unless query.nil?
    return list
  end

  def latest limit=5
    mtime_sort(find_f)[0..(limit-1)]
  end

  def list path=store
    Dir[ File.join(path, "*") ]
  end

  def mtime_sort list
    (list.sort_by! { |i| File.mtime(i) }).sort! { |x,y| y <=> x } unless list.count == 0
  end

  def delete path
    File.delete path
  end

  def create path, data
    FileUtils.mkdir_p(File.dirname(path)) unless File.directory?(File.dirname(path))
    raise StandardError, "File found, it shouldn't have been!" if File.exists?(path)
    FileUtils.touch(path)
    update(path, data)
  end

  def update path, data
    raise StandardError, "File not found!" unless File.exists?(path)
    file_handle = File.open(path, "w")
    file_handle.write(data)
    file_handle.close
    true
  end

  # pure display helpers
  def post_contents path
    raise StandardError, "File not found!" unless File.exists?(path)
    File.read(path)
  end

  def post_title path
    path.split("/").last.split(".").first
  end

  def dir_link path
    parts = path.split("/")
    path = parts[-2..parts.count].join("/")
    # TODO: should be different
    "<a href='#{path}'>#{path}</a>"
  end
end
