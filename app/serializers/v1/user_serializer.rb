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
module V1
  class UserSerializer < ApplicationSerializer

    attributes :id, :username, :first_name, :last_name, :groups, :api_key, :api_key_expires_at

  end
end
