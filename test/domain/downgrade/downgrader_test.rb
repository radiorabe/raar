require 'test_helper'

module Downgrade
  class DowngraderTest < ActiveSupport::TestCase

    test 'actions contain only those with bitrate' do
      assert !Downgrade::Downgrader.actions.map(&:bitrate).include?(nil)
    end

    test 'creates lower-bitrate file and deletes higher-bitrate one' do
      b1 = Broadcast.create!(show: shows(:g9s),
                             started_at: Time.zone.local(2012, 12, 12, 20),
                             finished_at: Time.zone.local(2012, 12, 12, 22))
      file = AudioFile.create!(broadcast: b1,
                               path: 'dummy_higher',
                               audio_format: 'mp3',
                               bitrate: 224,
                               channels: 2)
      home = FileStore::Structure.home
      path = File.join('2012', '12', '12', '2012-12-12T190000Z_192_2.mp3')
      AudioProcessor::Ffmpeg.any_instance.expects(:downgrade).with(File.join(home, path), 192, 2)
      assert_no_difference('AudioFile.count') do
        downgrader.handle(file)
      end
      assert !AudioFile.where(id: file.id).exists?
      lower = AudioFile.where(broadcast_id: b1.id, bitrate: 192, channels: 2).first
      assert_equal path, lower.path
    end

    test 'just deletes higher-bitrate file when lower-bitrate already exists' do
      higher = audio_files(:info_april_best)
      lower = audio_files(:info_april_high)
      File.expects(:exist?).with(lower.absolute_path).returns(true)
      File.expects(:exist?).with(higher.absolute_path).returns(true)
      FileUtils.expects(:rm).with(higher.absolute_path)
      AudioProcessor::Ffmpeg.any_instance.expects(:downgrade).never
      assert_difference('AudioFile.count', -1) do
        downgrader.handle(higher)
      end
      assert !AudioFile.where(id: higher.id).exists?
    end

    test 're-creates lower-bitrate file even if database entry exists' do
      higher = audio_files(:info_april_best)
      lower = audio_files(:info_april_high)
      home = FileStore::Structure.home
      File.expects(:exist?).with(lower.absolute_path).returns(false)
      File.expects(:exist?).with(higher.absolute_path).returns(false)
      AudioProcessor::Ffmpeg.any_instance
        .expects(:downgrade)
        .with(File.join(home, lower.path), 192, 2)
      assert_difference('AudioFile.count', -1) do
        downgrader.handle(higher)
      end
      assert !AudioFile.where(id: higher.id).exists?
    end

    test 're-creates database entry if lower-bitrate file exists' do
      higher = audio_files(:info_april_best)
      lower = audio_files(:info_april_high)
      File.expects(:exist?).with(lower.absolute_path).returns(true)
      File.expects(:exist?).with(higher.absolute_path).returns(false)
      AudioProcessor::Ffmpeg.any_instance.expects(:downgrade).never
      lower.destroy!
      assert_no_difference('AudioFile.count') do
        downgrader.handle(higher)
      end
      assert !AudioFile.where(id: higher.id).exists?
      assert AudioFile.where(broadcast_id: lower.broadcast_id,
                             audio_format: 'mp3',
                             bitrate: 192,
                             channels: 2).exists?
    end

    test 'finds files with higher bitrate' do
      b1 = Broadcast.create!(show: shows(:g9s),
                             started_at: Time.zone.local(2012, 12, 12, 20),
                             finished_at: Time.zone.local(2012, 12, 12, 22))
      lower  = AudioFile.create!(broadcast: b1,
                                 path: 'dummy_lower',
                                 audio_format: 'mp3',
                                 bitrate: 128,
                                 channels: 1)
      same   = AudioFile.create!(broadcast: b1,
                                 path: 'dummy_same',
                                 audio_format: 'mp3',
                                 bitrate: 192,
                                 channels: 2)
      higher = AudioFile.create!(broadcast: b1,
                                 path: 'dummy_higher',
                                 audio_format: 'mp3',
                                 bitrate: 224,
                                 channels: 2)
      start = Time.zone.now - action.months.months + 1.day
      b2 = Broadcast.create!(show: shows(:g9s),
                             started_at: start,
                             finished_at: start + 2.hours)
      newer  = AudioFile.create!(broadcast: b2,
                                 path: 'dummy_newer',
                                 audio_format: 'mp3',
                                 bitrate: 224,
                                 channels: 2)
      b3 = Broadcast.create!(show: shows(:klangbecken),
                             started_at: Time.zone.local(2012, 12, 12, 22),
                             finished_at: Time.zone.local(2012, 12, 13, 8))
      different  = AudioFile.create!(broadcast: b3,
                                     path: 'dummy_different_profile',
                                     audio_format: 'mp3',
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
