# == Schema Information
#
# Table name: broadcasts
#
#  id          :integer          not null, primary key
#  show_id     :integer          not null
#  label       :string           not null
#  started_at  :datetime         not null
#  finished_at :datetime         not null
#  people      :string
#  details     :text
#

require 'test_helper'

class BroadcastTest < ActiveSupport::TestCase
  test "all fixtures valid" do
    Broadcast.all.each do |e|
      assert_valid e
    end
  end
end
