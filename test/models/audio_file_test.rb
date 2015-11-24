# == Schema Information
#
# Table name: audio_files
#
#  id                 :integer          not null, primary key
#  broadcast_id       :integer          not null
#  path               :string           not null
#  bitrate            :integer          not null
#  channels           :integer          not null
#  archive_format_id  :integer          not null
#  playback_format_id :integer
#

require 'test_helper'

class AudioFileTest < ActiveSupport::TestCase
  test "all fixtures valid" do
    AudioFile.all.each do |e|
      assert e.valid?, "#{e} is not valid"
    end
  end
end
