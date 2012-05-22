module Ditty
  class Comment 
    include MongoMapper::Document
    key :title,         String
    key :body,          String
    key :post_id,       BSON::ObjectId
    key :created_by,    String
    timestamps!
  end
end

