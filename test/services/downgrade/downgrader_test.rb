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
                               codec: 'mp3',
                               bitrate: 224,
                               channels: 2)
      home = FileStore::Structure.home
      path = File.join('2012', '12', '12', '2012-12-12T200000+0100_120_gschach9schlimmers.192k_2.mp3')

      AudioProcessor::Ffmpeg.any_instance.
        expects(:transcode).
        with(File.join(home, path), AudioFormat.new('mp3', 192, 2))

      assert_no_difference('AudioFile.count') do
        downgrader.handle(file)
      end
      assert !AudioFile.where(id: file.id).exists?
      lower = AudioFile.where(broadcast_id: b1.id, bitrate: 192, channels: 2).first
      assert_equal path, lower.path
    end

    test 'creates one lower-bitrate file from highest and deletes all higher-bitrate ones' do
      b1 = Broadcast.create!(show: shows(:g9s),
                             started_at: Time.zone.local(2012, 12, 12, 20),
                             finished_at: Time.zone.local(2012, 12, 12, 22))
      file1 = AudioFile.create!(broadcast: b1,
                                path: 'dummy_highest',
                                codec: 'mp3',
                                bitrate: 320,
                                channels: 2)
      file2 = AudioFile.create!(broadcast: b1,
                                path: 'dummy_higher1',
                                codec: 'mp3',
                                bitrate: 256,
                                channels: 1)
      file3 = AudioFile.create!(broadcast: b1,
                                path: 'dummy_higher2',
                                codec: 'mp3',
                                bitrate: 224,
                                channels: 2)
      home = FileStore::Structure.home
      path = File.join('2012', '12', '12', '2012-12-12T200000+0100_120_gschach9schlimmers.192k_2.mp3')

      AudioProcessor::Ffmpeg.any_instance.
        expects(:transcode).
        with(File.join(home, path), AudioFormat.new('mp3', 192, 2))

      File.expects(:exist?).with(File.join(home, path)).at_least(1).returns(false, true, true)
      [file1, file2, file3].each do |file|
        File.expects(:exist?).with(file.absolute_path).returns(true)
        FileUtils.expects(:rm).with(file.absolute_path)
      end

      assert_difference('AudioFile.count', -2) do
        [file1, file2, file3].shuffle.each { |file| downgrader.handle(file) }
      end
      assert !AudioFile.where(id: file1.id).exists?
      assert !AudioFile.where(id: file2.id).exists?
      assert !AudioFile.where(id: file3.id).exists?
      lower = AudioFile.where(broadcast_id: b1.id, bitrate: 192, channels: 2).first
      assert_equal path, lower.path
    end

    test 'just deletes higher-bitrate file when lower-bitrate already exists' do
      higher = audio_files(:info_april_best)
      lower = audio_files(:info_april_high)

      File.expects(:exist?).with(lower.absolute_path).returns(true)
      File.expects(:exist?).with(higher.absolute_path).returns(true)
      FileUtils.expects(:rm).with(higher.absolute_path)
      AudioProcessor::Ffmpeg.any_instance.expects(:transcode).never

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
        .expects(:transcode)
        .with(File.join(home, lower.path), AudioFormat.new('mp3', 192, 2))

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
      AudioProcessor::Ffmpeg.any_instance.expects(:transcode).never

      lower.destroy!

      assert_no_difference('AudioFile.count') do
        downgrader.handle(higher)
      end
      assert !AudioFile.where(id: higher.id).exists?
      assert AudioFile.where(broadcast_id: lower.broadcast_id,
                             codec: 'mp3',
                             bitrate: 192,
                             channels: 2).exists?
    end

    test 'finds files with higher bitrate' do
      b1 = Broadcast.create!(show: shows(:g9s),
                             started_at: Time.zone.local(2012, 12, 12, 20),
                             finished_at: Time.zone.local(2012, 12, 12, 22))
      lower  = AudioFile.create!(broadcast: b1,
                                 path: 'dummy_lower',
                                 codec: 'mp3',
                                 bitrate: 128,
                                 channels: 1)
      same   = AudioFile.create!(broadcast: b1,
                                 path: 'dummy_same',
                                 codec: 'mp3',
                                 bitrate: 192,
                                 channels: 2)
      higher = AudioFile.create!(broadcast: b1,
                                 path: 'dummy_higher',
                                 codec: 'mp3',
                                 bitrate: 224,
                                 channels: 2)
      start = Time.zone.now - action.months.months + 1.day
      b2 = Broadcast.create!(show: shows(:g9s),
                             started_at: start,
                             finished_at: start + 2.hours)
      newer  = AudioFile.create!(broadcast: b2,
                                 path: 'dummy_newer',
                                 codec: 'mp3',
                                 bitrate: 224,
                                 channels: 2)
      b3 = Broadcast.create!(show: shows(:klangbecken),
                             started_at: Time.zone.local(2012, 12, 12, 22),
                             finished_at: Time.zone.local(2012, 12, 13, 8))
      different  = AudioFile.create!(broadcast: b3,
                                     path: 'dummy_different_profile',
                                     codec: 'mp3',
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
