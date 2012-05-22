module Ditty
  class Tag
    include MongoMapper::Document
    key :tag,     String, :unique => true
    key :post_id, Array,  :typecast => 'ObjectId'
    timestamps!

    def count
      self.post_id.count
    end

    def push id
      self.post_id.push(id) unless self.post_id.include? id
      self.post_id
    end

    def has_id? id
      self.post_id.include?(id)
    end

  end
end

