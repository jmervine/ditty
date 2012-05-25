require './lib/ditty'
module Ditty
  class Item 
    include MongoMapper::Document
    set_collection_name "ditty.posts"
    key :title,         String
    key :body,          String
    #key :created_at,    Time
    #key :updated_at,    Time
    timestamps!
  end
end
