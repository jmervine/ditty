class Comment
  include Mongoid::Document

  field :comment, type: String

  belongs_to :post#, index: true
  belongs_to :mongoid_user#, index: true
  index({ name: 1 }, { unique: true })

end

