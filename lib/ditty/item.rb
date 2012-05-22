require './lib/ditty'
module Ditty
  class Item 
    include MongoMapper::Document
    key :title,         String
    key :body,          String
    #key :created_at,    Time
    #key :updated_at,    Time
    timestamps!
  end
end
