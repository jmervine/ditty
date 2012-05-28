class Post 
  include MongoMapper::Document
  before_create :create_title_path
  before_update :update_title_path
  key :title,         String
  key :title_path,    String#, :unique => true
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

  private
  def set_title_path time
    clean_title = self.title.clone
    ["|", "%", "/", ":", "=", "&", "?", "~", "#", "+", "!", "$", ",", ";", "'", "@", "(", ")", "*", "[", "]", '"'].each do |ugly|
      clean_title.gsub!(ugly, "")
    end
    [" ", ".", Regexp.new("[\_]{1,}")].each do |ugly|
      clean_title.gsub!(ugly, "_")
    end
    clean_title.gsub!(/_$/, "")
    new_title_path = time.strftime("/%Y/%m/%d/")
    new_title_path << clean_title
    self.title_path = new_title_path.downcase
  end

  def create_title_path 
    set_title_path(Time.now)
  end

  def update_title_path
    set_title_path(self.created_at)
  end

end
