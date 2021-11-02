# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  title      :text
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  validates :title, presence: true, length: {minimum: 5}
  validates :body, presence: true
end
