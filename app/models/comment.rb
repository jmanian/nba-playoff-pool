# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  name       :string
#  body       :text
#  post_id    :bigint           not null, indexed
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Comment < ApplicationRecord
  belongs_to :post
end
