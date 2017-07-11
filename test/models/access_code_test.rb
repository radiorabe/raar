# == Schema Information
#
# Table name: access_codes
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  expires_at :date
#

require 'test_helper'

class AccessCodeTest < ActiveSupport::TestCase

  test 'generates code on creation' do
    code = AccessCode.new(expires_at: 1.months.from_now)
    assert code.save
    assert_equal AccessCode::CODE_LENGTH, code.code.size
  end

end
