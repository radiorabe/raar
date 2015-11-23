# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  username           :string           not null
#  first_name         :string
#  last_name          :string
#  groups             :string
#  api_key            :string
#  api_key_expires_at :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class User < ActiveRecord::Base

  validates :username, presence: true, uniqueness: true

end
