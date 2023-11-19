# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string           not null
#  first_name      :string           not null
#  last_name       :string           not null
#  password_digest :string           not null
#  username        :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "Must enter a valid email address"}
  validates :password, presence: true
  validates :username, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
end
