
   
# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  body       :text
#  post_id    :bigint           not null, indexed
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#  name       :text
#
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
end
