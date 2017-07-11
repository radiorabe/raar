# == Schema Information
#
# Table name: archive_formats
#
#  id                      :integer          not null, primary key
#  profile_id              :integer          not null
#  codec                   :string           not null
#  initial_bitrate         :integer          not null
#  initial_channels        :integer          not null
#  max_public_bitrate      :integer
#  created_at              :datetime
#  updated_at              :datetime
#  download_permission     :integer
#  max_logged_in_bitrate   :integer
#  max_priviledged_bitrate :integer
#  priviledged_groups      :string
#

require 'test_helper'

class ArchiveFormatTest < ActiveSupport::TestCase

  test 'all fixtures valid' do
     ArchiveFormat.all.each do |e|
       assert_valid e
     end
  end

  test 'validates available bitrates' do
    entry = ArchiveFormat.new(codec: 'mp3', initial_bitrate: 123, initial_channels: 6)
    assert_not_valid entry, :initial_bitrate, :initial_channels, :profile
  end

  test 'validates available codecs' do
    entry = ArchiveFormat.new(codec: 'mp4', initial_bitrate: 96, initial_channels: 2)
    assert_not_valid entry, :codec, :profile
  end

  test 'codec is not changeable anymore' do
    p = Profile.create!(name: 'test')
    entry = ArchiveFormat.create!(profile: p,
                                  codec: 'mp3',
                                  initial_bitrate: 96,
                                  initial_channels: 2)
    entry.codec = 'flac'
    entry.initial_bitrate = 1
    assert_not_valid entry, :codec
  end

end
