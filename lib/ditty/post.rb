class Post 
  include Mongoid::Document
  include Mongoid::Timestamps
  validates_presence_of :title
  validates_uniqueness_of :title_path
  before_create :create_title_path
  before_update :update_title_path

  field :title, type: String
  field :title_path, type: String
  field :body, type: String

  has_and_belongs_to_many :tags, index: true
  has_many :comments
  belongs_to :mongoid_user

  index({ title_path: 1 }, { unique: true })

  def associate_or_create_tag name
    tag = Tag.where(:name => name).first 
    self.tags.create(:name => name) if tag.nil?
    self.tags.push(tag) unless self.tags.include?(tag)
    self.save!
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
