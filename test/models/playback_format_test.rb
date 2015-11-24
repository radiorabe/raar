# == Schema Information
#
# Table name: playback_formats
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  description  :text
#  audio_format :string           not null
#  bitrate      :integer          not null
#  channels     :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class PlaybackFormatTest < ActiveSupport::TestCase
  test "all fixtures valid" do
    PlaybackFormat.all.each do |e|
      assert e.valid?, "#{e} is not valid"
    end
  end
end
