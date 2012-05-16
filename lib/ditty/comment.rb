require './lib/ditty/item'
module Ditty
  class Comment < Item
    def keys_public
      super+[ "post_id", "created_by" ]
    end
  end
end

