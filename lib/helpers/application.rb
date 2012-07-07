require 'digest/sha1'
module Helper
  module Application
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
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [settings.username, settings.password]
    end

    def choose_layout
      return :mobile if is_mobile?
      return :layout
    end

    def choose_template template
      return "mobile_#{template.to_s}".to_sym if is_mobile?
      return template
    end

    def is_mobile?
      return true if request.env['X_MOBILE_DEVICE']
      return false
    end

    def seperate_post_tags post
      tags = []
      if post['tags']
        tags = post['tags'].split(',').map { |tag| tag.strip.downcase }
        post.delete('tags')
      end
      return [post, tags]
    end

    def get_posts_from_tag tag
      Tag.where(:name => tag).first.posts.reverse rescue []
    end

    def tags_sorted_by_count
      (Tag.all.sort_by { |t| t.posts.count })
    end

    def cache_sha key
      Digest::SHA1.hexdigest((is_mobile? ? 'm' : 'd') + key)
    end

  end
end
