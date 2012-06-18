class Tag
  include Mongoid::Document
  validates_presence_of :name
  validates_uniqueness_of :name

  field :name, type: String

  has_and_belongs_to_many :posts, index: true
  index({ name: 1 }, { unique: true })

end
