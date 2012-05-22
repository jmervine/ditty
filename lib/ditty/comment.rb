require './lib/ditty/item'
module Ditty
  class Comment < Item
    key :post_id,       BSON::ObjectId
    key :created_by,    String
  end
end

