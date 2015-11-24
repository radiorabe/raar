# == Schema Information
#
# Table name: profiles
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :text
#  default     :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  test "all fixtures valid" do
    Profile.all.each do |e|
      assert e.valid?, "#{e} is not valid"
    end
  end
end
