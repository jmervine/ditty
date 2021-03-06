require 'open-uri'
require 'tzinfo'
require 'helpers'
module Helper
  module Templates
    def post_contents post
      return "" if post.nil? or post.body.nil?
      markdown post.body
    end

    def time_display post
      return "" if post.nil? or post.created_at.nil?
      post_time = post.created_at.utc
      begin
        time_zone = TZInfo::Timezone.get(settings.timezone) 
        zone_time = time_zone.utc_to_local(post_time)
      rescue
        logger.info "Timezone Error (#{settings.timezone})!"
        zone_time = post_time
      end
      if Time.now.utc.to_i > post_time.to_i+(60*60*24)
        "<span class='header_time'>Created on #{zone_time.strftime("%B %d, %Y")}</span>"
      else
        "<span class='header_time'>Created at #{zone_time.strftime("%r")}</span>"
      end
    end

    def post_tags post
      (Tag.where( :post_id => post.id ).map { |t| t.tag }).compact.sort.join(" ")
    end

    def post_title post
      return "" if post.nil?
      post.title
    end

    def archive_link year, month=nil
      if month.nil?
        path = year.to_s
        name = path
      else
        path  = "#{year}/#{"%02d" % month}"
        name  = months[month.to_i-1].capitalize
      end
      return name if request.path_info =~ Regexp.new(Regexp.escape(path)+"(\/?)$")
      return "<a href='/#{path}'>#{name}</a>" 
    end

    def post_tag_string tags
      (tags.map { |t| t.name }).join(", ")
    end

    def archive_items
      collection = Post.all.desc(:created_at)
      archive = {}
      # TODO: there has to be a better way
      collection.each do |item| 
        date = item.created_at
        archive[date.year] = {} unless archive.has_key? date.year
        archive[date.year][date.month] = [] unless archive[date.year].has_key? date.month
        archive[date.year][date.month].push item
      end
      archive
    end

    def archive_list archive=nil
      archive = archive_items if archive.nil?

      markup = ""
      markup << %{ <ul class="nav_list"> }

      archive.each_key do |year|
        markup << %{ <li class="nav_item"><b>#{archive_link(year)}</b></li> }
        markup << %{ <ul class="nav_sub_list"> }
        archive[year].each_key do |month|
          markup << %{ <li class="nav_item">#{ archive_link(year, month) }</li> }
          markup << %{ <ul class="nav_sub_list"> }
          archive[year][month].each do |item|
            markup << %{ <li class="nav_item">#{ post_link(item) }</li> }
          end
          markup << %{ </ul> }
          markup << %{ </li> }
        end
        markup << %{ </ul> }
        markup << %{ </li> }
      end
      markup << %{ </ul> }
      markup
    end

    def post_link post
      return "" if post.nil? or post.id.blank?
      "<a href='#{post.title_path}'>#{post.title}</a>"
    end
      
    def months
      %w{ january february march april may june july august september october november december }
    end

    #def latest n=25
      #Post.all.desc(:created_at)[0..n-1]
    #end

    #def paginate page, show=10
      #p = Post.all.desc(:created_at)
      #if p.length >= (page+show)
        #return p[page..page+length]
      #elsif p.length >= page
        #return p[page..p.length]
      #else
        #n = (p.length%show)*show
        #return p[n..p.length]
      #end
    #end

    #def pagination page, path="/"
      #ppath = path.gsub!(/\/$/,"") 
      #markup = %{ <span class='pagination'> }
      #if page > 0
        #markup << %{ <a href="#{ppath/">first</a> }
        #(0..page).each do |n|
        #page_path = "#{path}/#{page}"
        #end
      #end
      #if page > 1
    #end

    #def pagination_link page, path
      #%{ <a href="#{path}/#{page}"> }
    #end

    def set_title_from_status state, post
      if state == :preview 
        return post["title"]
      elsif post.nil? or post.title.blank?
        return settings.title
      else
        return post_title(post)
      end
    end

    def set_state_class_from_state state
      if state == :index
        return "post_index"
      else
        return "post_show"
      end
    end

    protected
    # TODO: there has to be a better way
    def collection_sort collection, date_key="created_at"
      (collection.sort_by { |item| item[date_key] })
    end
    def collection_rsort collection, date_key="created_at"
      collection_sort(collection, date_key).reverse
    end
  end
end
