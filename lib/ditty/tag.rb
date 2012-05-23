module Ditty
  class Tag
  
    # TODO: add a smart way to remove tags from posts

    include MongoMapper::Document
    before_save :clean_post_id
    key :tag,     String, :unique => true
    key :post_id, Array,  :typecast => 'ObjectId'
    timestamps!

    def self.add( tag, id )
      this = self.where(:tag => tag)
      if this.count == 0
        this = self.create( :tag => tag, :post_id => [ id ] )
      else
        this = this.first
        this.push_id(id).save!
      end
      return this
    end

    def count
      self.post_id.count
    end

    def push_id id
      self.post_id.push(id)
      self
    end

    def has_id? id
      self.post_id.include?(id)
    end

    private
    def clean_post_id
      self.post_id.uniq!
    end
  end
end

