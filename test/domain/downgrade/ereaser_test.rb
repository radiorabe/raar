require 'test_helper'

module Downgrade
  class EreaserTest < ActiveSupport::TestCase

    test 'actions contain only those without bitrate' do
      assert_equal [nil], Downgrade::Ereaser.actions.map(&:bitrate).uniq
    end

    test 'finds files with higher bitrate' do
      format = archive_formats(:unimportant_mp3)
      AudioFile.destroy_all

      b1 = Broadcast.create!(show: shows(:klangbecken),
                             started_at: Time.zone.local(2012, 12, 12, 20),
                             finished_at: Time.zone.local(2012, 12, 12, 22))
      file  = AudioFile.create!(broadcast: b1,
                                path: 'dummy_lower',
                                codec: 'mp3',
                                bitrate: 128,
                                channels: 1)

      start = Time.zone.now - action.months.months + 1.day
      b2 = Broadcast.create!(show: shows(:klangbecken),
                             started_at: start,
                             finished_at: start + 2.hours)
      newer  = AudioFile.create!(broadcast: b2,
                                 path: 'dummy_newer',
                                 codec: 'mp3',
                                 bitrate: 224,
                                 channels: 2)

      assert_equal [file], ereaser.pending_files
    end

    def ereaser
      Downgrade::Ereaser.new(action)
    end

    def action
      downgrade_actions(:unimportant_mp3_1)
    end

  end
end
