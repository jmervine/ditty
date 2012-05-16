require 'open-uri'
module HelpersTemplates

  def post_contents post
    markdown post.body
  end

  def time_display post
    action = (post.created_at == post.updated_at ? "Created" : "Updated")
    mt = post.updated_at
    nt = Time.now
    if nt.to_i > mt.to_i+(60*60*24)
      "<span class='header_time'>#{action} on #{mt.strftime("%B %d, %Y")}</span>"
    else
      "<span class='header_time'>#{action} at #{mt.strftime("%r")}</span>"
    end
  end

  def post_title post
    post.title
  end

  def archive_link year, month
    month = "%02d" % month
    if request.path_info =~ Regexp.new("#{year}\/#{month}$")
      return months[month.to_i-1].capitalize
    else
      return "<a href='/archive/#{year}/#{month}'>#{months[month.to_i-1].capitalize}</a>" 
    end
  end

  def archive_items
    date_key="created_at"
    collection = settings.store.find
    archive = {}
    # TODO: there has to be a better way
    collection_sort(collection).each do |item| 
      date = Time.parse(item[date_key]) rescue item[date_key]
      archive[date.year] = [] unless archive.has_key? date.year
      archive[date.year].push date.month unless archive[date.year].include? date.month
    end
    archive
  end

  def archive_list 
    archive = archive_items
    markup = ""
    markup << %{ <ul class="nav_list"> }
    archive.each_key do |year|
      markup << %{ <li class="nav_item"><b>#{year}</b></li> }
      markup << %{ <ul class="nav_sub_list"> }
      archive[year].each do |month|
        markup << %{ <li class="nav_item">#{ archive_link(year, month) }</li> }
      end
      markup << %{ </ul> }
      markup << %{ </li> }
    end
    markup << %{ </ul> }
    markup
  end

  def post_link post, use_title=false
    link = if use_title
             linkify_title(post_title(post)) 
           else
             post.id.to_s
           end
    "<a href='/post/#{link}'>#{post_title(post)}</a>"
  end
    
  def months
    %w{ january february march april may june july august september october november december }
  end

  # TODO: don't store id and then create post, just store post and create it
  def latest n=5
    ids = collection_sort(settings.store.find)[0..n-1].collect { |i| i["_id"] }
    ids.collect { |id| Ditty::Post.load id }
  end

  def linkify_title title
    URI::encode title
  end

  def delinkify_title title
    URI::decode title
  end

  protected
  # TODO: there has to be a better way
  def collection_sort collection, date_key="created_at"
    (collection.sort_by { |item| item[date_key] }).reverse
  end
end
