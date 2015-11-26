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
      assert_valid e
    end
  end

  test 'default flag may be changed' do
    p = profiles(:important)
    p.default = true
    p.save!
    assert_equal false, profiles(:default).default
  end

  test 'default flag may not be removed' do
    p = profiles(:default)
    p.default = false
    assert_not_valid p, :default
  end

  test 'non-default profile may be created' do
    p = Profile.new(name: 'foo', default: false)
    assert_valid p
  end

  test 'default profile my be created' do
    p = Profile.new(name: 'foo', default: true)
    assert_valid p
    p.save!
    assert_equal false, profiles(:default).default
  end

end
