# frozen_string_literal: true

# == Schema Information
#
# Table name: access_codes
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  expires_at :date
#  created_at :datetime
#  creator_id :integer
#

require 'test_helper'

class AccessCodeTest < ActiveSupport::TestCase

  test 'generates code on creation' do
    code = AccessCode.new(expires_at: 1.month.from_now)
    assert code.save
    assert_equal AccessCode::CODE_LENGTH, code.code.size
  end

  test '.expired' do
    today = Time.zone.today
    c1 = AccessCode.create!(expires_at: today)
    c2 = AccessCode.create!(expires_at: today + 1.day)
    c3 = AccessCode.create!(expires_at: today - 1.day)
    c4 = AccessCode.create!(expires_at: today - 1.year)
    assert_equal [c3, c4], AccessCode.expired.list
  end

end
