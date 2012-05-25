class Post 
  include MongoMapper::Document
  key :title,         String
  key :body,          String
  key :tag_ids,       Array
  timestamps!
  many :tags, :in => :tag_ids

  def add_tags tags
    tags.each do |tag| 
      tag_obj = Tag.where(:name => tag).first
      if tag_obj.nil?
        self.tags.create(:name => tag)
      else
        unless self.tag_ids.include? tag_obj.id
          self.tag_ids.push tag_obj.id 
        end
      end
    end
    self.save!
    self
  end
  def add_tag tag
    tag_obj = Tag.where(:name => tag).first
    if tag_obj.nil?
      self.tags.create(:name => tag)
    else
      unless self.tag_ids.include? tag_obj.id
        self.tag_ids.push tag_obj.id 
        self.save!
      end
    end
    self
  end
end
