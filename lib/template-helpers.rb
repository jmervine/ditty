module TemplateHelpers

  def post_contents path
    raise StandardError, "File not found (#{path})!" unless File.exists?(path)
    fh = File.open(path, "r")
    file = fh.read
    fh.close
    return file
  end

  def post_title path
    (File.basename(path, ".*").gsub("_", " ").gsub("-", " ").split.map! { |i| i.capitalize! }).join(" ")
  end

  def archive_link path
    link = path.gsub!(settings.store, "/archive")
    text = path.split("/").last
    text = months[text.to_i-1].capitalize if text.to_i < 13
    "<a href='#{link}'>#{text}</a>" 
  end

  def post_link path
    link = path.gsub!(settings.store, "/post")
    "<a href='#{link}'>#{post_title(path)}</a>"
  end
    
  def months
    %w{ january february march april may june july august september october november december }
  end
end
