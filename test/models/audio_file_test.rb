# == Schema Information
#
# Table name: audio_files
#
#  id                 :integer          not null, primary key
#  broadcast_id       :integer          not null
#  path               :string           not null
#  audio_format       :string           not null
#  bitrate            :integer          not null
#  channels           :integer          not null
#  playback_format_id :integer
#  created_at         :datetime         not null
#

require 'test_helper'

class AudioFileTest < ActiveSupport::TestCase
  test "all fixtures valid" do
    AudioFile.all.each do |e|
      assert_valid e
    end
  end
end
