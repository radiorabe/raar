# == Schema Information
#
# Table name: shows
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  details    :text
#  profile_id :integer          not null
#

require 'test_helper'

class ShowTest < ActiveSupport::TestCase
  test "all fixtures valid" do
    Show.all.each do |e|
      assert_valid e
    end
  end
end
