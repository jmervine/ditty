class Tag
  include MongoMapper::Document
  key :name,     String, :unique => true
  def posts
    Post.where(:tag_ids => self.id).sort(:update_at.desc).to_a
  end
  def destroy
    Post.where(:tag_ids => self.id).each do |post|
      post.tag_ids.delete(self.id)
      post.save!
    end
    super
  end
end
