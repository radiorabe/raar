require 'test_helper'

module Downgrade
  class DowngraderTest < ActiveSupport::TestCase

    test 'actions contain only those with bitrate' do
      assert !Downgrade::Downgrader.actions.map(&:bitrate).include?(nil)
    end

    test 'finds files with higher bitrate' do
      b1 = Broadcast.create!(show: shows(:g9s),
                             started_at: Time.zone.local(2012, 12, 12, 20),
                             finished_at: Time.zone.local(2012, 12, 12, 22))
      lower  = AudioFile.create!(broadcast: b1,
                                 archive_format: archive_formats(:default_mp3),
                                 path: 'dummy_lower',
                                 bitrate: 128,
                                 channels: 1)
      same   = AudioFile.create!(broadcast: b1,
                                 archive_format: archive_formats(:default_mp3),
                                 path: 'dummy_same',
                                 bitrate: 192,
                                 channels: 2)
      higher = AudioFile.create!(broadcast: b1,
                                 archive_format: archive_formats(:default_mp3),
                                 path: 'dummy_higher',
                                 bitrate: 224,
                                 channels: 2)
      start = Time.zone.now - action.months.months + 1.day
      b2 = Broadcast.create!(show: shows(:g9s),
                             started_at: start,
                             finished_at: start + 2.hours)
      newer  = AudioFile.create!(broadcast: b2,
                                 archive_format: archive_formats(:default_mp3),
                                 path: 'dummy_newer',
                                 bitrate: 224,
                                 channels: 2)
      assert_equal [higher], downgrader.pending_files
    end

    def downgrader
      Downgrade::Downgrader.new(action)
    end

    def action
      downgrade_actions(:default_mp3_1)
    end

  end
end
