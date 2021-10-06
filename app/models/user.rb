# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null, indexed
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string           indexed
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  username               :string           not null, indexed
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  admin                  :boolean          default(FALSE), not null
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  # Model was originally generated with :recoverable, but was removed
  # until we can add email ability.
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  validates :username, uniqueness: true

  has_many :picks, dependent: :restrict_with_exception

  def title
    email
  end
end
