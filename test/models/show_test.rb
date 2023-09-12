# frozen_string_literal: true

# == Schema Information
#
# Table name: shows
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  details    :text
#  profile_id :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  creator_id :integer
#  updater_id :integer
#

require 'test_helper'

class ShowTest < ActiveSupport::TestCase

  test 'all fixtures valid' do
    Show.find_each do |e|
      assert_valid e
    end
  end

end
