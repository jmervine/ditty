require 'open-uri'
module TemplateHelpers

  def post_contents path
    markdown file_contents(path)
  end

  def file_contents path
    raise StandardError, "File not found (#{path})!" unless File.exists?(path)
    fh = File.open(path, "r")
    file = fh.read
    fh.close 
    file
  end

  def time_display path
    "<span class='header_time'>Updated: #{Time.at(File.mtime(path)).strftime("%B %d, %Y at %r")}</span>"
  end

  def post_title path
    (URI::decode(File.basename(path, ".*")).gsub("_", " ").split.map! { |i| i.capitalize! }).join(" ")
  end

  def post_file string
    string.gsub!(" ", "_")
    URI::encode(string)
  end

  def archive_link path
    link = path.gsub!(settings.store, "/archive")
    text = path.split("/").last
    text = months[text.to_i-1].capitalize if text.to_i < 13
    if request.path_info =~ Regexp.new(link)
      return text
    else
      return "<a href='#{link}'>#{text}</a>" 
    end
  end

  def post_link path
    link = path.gsub!(settings.store, "/post")
    "<a href='#{link}'>#{post_title(path)}</a>"
  end
    
  def months
    %w{ january february march april may june july august september october november december }
  end
end
