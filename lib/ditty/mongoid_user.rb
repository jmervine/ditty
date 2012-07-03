class MongoidUser
  include Mongoid::Document
  has_many :comments, dependent: :delete
  has_many :posts, dependent: :delete
end

