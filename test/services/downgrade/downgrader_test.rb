# frozen_string_literal: true

require 'test_helper'

module Downgrade
  class DowngraderTest < ActiveSupport::TestCase

    test 'actions contain only those with bitrate' do
      assert_not Downgrade::Downgrader.actions.map(&:bitrate).include?(nil)
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

      AudioProcessor::Ffmpeg.any_instance
                            .expects(:transcode)
                            .with(is_a(String), AudioFormat.new('mp3', 192, 2))
      FileUtils.expects(:mv).with(is_a(String), File.join(home, path))

      assert_no_difference('AudioFile.count') do
        downgrader.handle(file)
      end
      assert_not AudioFile.exists?(id: file.id)
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
                                channels: 1)
      file2 = AudioFile.create!(broadcast: b1,
                                path: 'dummy_higher1',
                                codec: 'mp3',
                                bitrate: 256,
                                channels: 2)
      file3 = AudioFile.create!(broadcast: b1,
                                path: 'dummy_higher2',
                                codec: 'mp3',
                                bitrate: 224,
                                channels: 2)
      home = FileStore::Structure.home
      path = File.join('2012', '12', '12', '2012-12-12T200000+0100_120_gschach9schlimmers.192k_2.mp3')

      proc = AudioProcessor::Ffmpeg.new('foo')
      AudioProcessor.expects(:new).with(file2.absolute_path).returns(proc)
      proc
        .expects(:transcode)
        .with(is_a(String), AudioFormat.new('mp3', 192, 2))
      FileUtils.expects(:mv).with(is_a(String), File.join(home, path))

      downgrader.expects(:file_exists?).with(File.join(home, path)).at_least(1).returns(false, true, true)
      [file1, file2, file3].each do |file|
        downgrader.expects(:file_exists?).with(file.absolute_path).returns(true)
        FileUtils.expects(:rm).with(file.absolute_path)
      end

      assert_difference('AudioFile.count', -2) do
        [file1, file2, file3].shuffle.each { |file| downgrader.handle(file) }
      end
      assert_not AudioFile.exists?(id: file1.id)
      assert_not AudioFile.exists?(id: file2.id)
      assert_not AudioFile.exists?(id: file3.id)
      lower = AudioFile.where(broadcast_id: b1.id, bitrate: 192, channels: 2).first
      assert_equal path, lower.path
    end

    test 'just deletes higher-bitrate file when lower-bitrate already exists' do
      higher = audio_files(:info_april_best)
      lower = audio_files(:info_april_high)

      downgrader.expects(:file_exists?).with(lower.absolute_path).returns(true)
      downgrader.expects(:file_exists?).with(higher.absolute_path).returns(true)
      FileUtils.expects(:rm).with(higher.absolute_path)
      AudioProcessor::Ffmpeg.any_instance.expects(:transcode).never

      assert_difference('AudioFile.count', -1) do
        downgrader.handle(higher)
      end
      assert_not AudioFile.exists?(id: higher.id)
    end

    test 're-creates lower-bitrate file even if database entry exists' do
      higher = audio_files(:info_april_best)
      lower = audio_files(:info_april_high)
      home = FileStore::Structure.home

      downgrader.expects(:file_exists?).with(lower.absolute_path).returns(false)
      downgrader.expects(:file_exists?).with(higher.absolute_path).returns(false)
      AudioProcessor::Ffmpeg.any_instance
                            .expects(:transcode)
                            .with(is_a(String), AudioFormat.new('mp3', 192, 2))
      FileUtils.expects(:mv).with(is_a(String), File.join(home, lower.path))

      assert_difference('AudioFile.count', -1) do
        downgrader.handle(higher)
      end
      assert_not AudioFile.exists?(id: higher.id)
    end

    test 're-creates database entry if lower-bitrate file exists' do
      higher = audio_files(:info_april_best)
      lower = audio_files(:info_april_high)

      downgrader.expects(:file_exists?).with(lower.absolute_path).returns(true)
      downgrader.expects(:file_exists?).with(higher.absolute_path).returns(false)
      AudioProcessor::Ffmpeg.any_instance.expects(:transcode).never

      lower.destroy!

      assert_no_difference('AudioFile.count') do
        downgrader.handle(higher)
      end
      assert_not AudioFile.exists?(id: higher.id)
      assert AudioFile.exists?(broadcast_id: lower.broadcast_id,
                               codec: 'mp3',
                               bitrate: 192,
                               channels: 2)
    end

    test 'finds files with higher bitrate' do
      b1 = Broadcast.create!(show: shows(:g9s),
                             started_at: Time.zone.local(2012, 12, 12, 20),
                             finished_at: Time.zone.local(2012, 12, 12, 22))
      lower = AudioFile.create!(broadcast: b1,
                                path: 'dummy_lower',
                                codec: 'mp3',
                                bitrate: 128,
                                channels: 1)
      same = AudioFile.create!(broadcast: b1,
                               path: 'dummy_same',
                               codec: 'mp3',
                               bitrate: 192,
                               channels: 2)
      higher = AudioFile.create!(broadcast: b1,
                                 path: 'dummy_higher',
                                 codec: 'mp3',
                                 bitrate: 224,
                                 channels: 2)
      higher_less_channels = AudioFile.create!(broadcast: b1,
                                               path: 'dummy_higher_less',
                                               codec: 'mp3',
                                               bitrate: 256,
                                               channels: 1)
      start = Time.zone.now - action.months.months + 1.day
      b2 = Broadcast.create!(show: shows(:g9s),
                             started_at: start,
                             finished_at: start + 2.hours)
      newer = AudioFile.create!(broadcast: b2,
                                path: 'dummy_newer',
                                codec: 'mp3',
                                bitrate: 224,
                                channels: 2)
      b3 = Broadcast.create!(show: shows(:klangbecken),
                             started_at: Time.zone.local(2012, 12, 12, 22),
                             finished_at: Time.zone.local(2012, 12, 13, 8))
      different = AudioFile.create!(broadcast: b3,
                                    path: 'dummy_different_profile',
                                    codec: 'mp3',
                                    bitrate: 224,
                                    channels: 2)
      assert_equal [higher, higher_less_channels].to_set, downgrader.pending_files.to_set
    end

    test 'finds files with higher bitrate with lower channel action' do
      b1 = Broadcast.create!(show: shows(:g9s),
                             started_at: Time.zone.local(2012, 12, 12, 20),
                             finished_at: Time.zone.local(2012, 12, 12, 22))
      lower = AudioFile.create!(broadcast: b1,
                                path: 'dummy_lower',
                                codec: 'mp3',
                                bitrate: 128,
                                channels: 2)
      same = AudioFile.create!(broadcast: b1,
                               path: 'dummy_same',
                               codec: 'mp3',
                               bitrate: 192,
                               channels: 2)
      higher = AudioFile.create!(broadcast: b1,
                                 path: 'dummy_higher',
                                 codec: 'mp3',
                                 bitrate: 224,
                                 channels: 2)

      downgrade_actions(:default_mp3_2).destroy!
      action.update!(channels: 1)
      assert_equal [higher, same, audio_files(:g9s_mai_high)].to_set, downgrader.pending_files.to_set
    end

    test 'highest is true if other has higher bitrate but less channels' do
      file = create_audio(bitrate: 224, channels: 2)
      other = create_audio(bitrate: 320, channels: 1)
      assert downgrader.highest?(file)
      assert_not downgrader.highest?(other)
    end

    test 'highest is false if other has higher bitrate and same channels' do
      file = create_audio(bitrate: 224, channels: 2)
      other = create_audio(bitrate: 320, channels: 2)
      assert_not downgrader.highest?(file)
      assert downgrader.highest?(other)
    end

    test 'highest is false if other has same bitrate and more channels' do
      file = create_audio(bitrate: 224, channels: 1)
      other = create_audio(bitrate: 224, channels: 2)
      assert_not downgrader.highest?(file)
      assert downgrader.highest?(other)
    end

    test 'highest is true if other has bitrate below action but more channels' do
      file = create_audio(bitrate: 320, channels: 1)
      other = create_audio(bitrate: 128, channels: 2)
      assert downgrader.highest?(file)
      # no assert for other because it would not be in pending_files
    end

    test 'highest is true if other has lower bitrate and both have less channels than action' do
      file = create_audio(bitrate: 320, channels: 1)
      other = create_audio(bitrate: 224, channels: 1)
      assert downgrader.highest?(file)
      assert_not downgrader.highest?(other)
    end

    test 'highest is true if other has lower bitrate or less channels' do
      file = create_audio(bitrate: 256, channels: 2)
      other1 = create_audio(bitrate: 320, channels: 1)
      other2 = create_audio(bitrate: 224, channels: 2)
      assert downgrader.highest?(file)
      assert_not downgrader.highest?(other1)
      assert_not downgrader.highest?(other2)
    end

    test 'highest is true if other has lower bitrate and more channels than action' do
      downgrade_actions(:default_mp3_2).destroy!
      action.update!(channels: 1)
      file = create_audio(bitrate: 320, channels: 1)
      other = create_audio(bitrate: 224, channels: 2)
      assert downgrader.highest?(file)
      assert_not downgrader.highest?(other)
    end

    test 'highest is true if other has lower bitrate and both have more channels than action' do
      downgrade_actions(:default_mp3_2).destroy!
      action.update!(channels: 1)
      file = create_audio(bitrate: 320, channels: 2)
      other = create_audio(bitrate: 224, channels: 2)
      assert downgrader.highest?(file)
      assert_not downgrader.highest?(other)
    end

    test 'highest is true if other has lower bitrate and both have same channels as action' do
      downgrade_actions(:default_mp3_2).destroy!
      action.update!(channels: 1)
      file = create_audio(bitrate: 320, channels: 1)
      other = create_audio(bitrate: 224, channels: 1)
      assert downgrader.highest?(file)
      assert_not downgrader.highest?(other)
    end

    test 'highest is true if other has lower bitrate' do
      downgrade_actions(:default_mp3_2).destroy!
      action.update!(channels: 1)
      file = create_audio(bitrate: 320, channels: 1)
      other1 = create_audio(bitrate: 256, channels: 2)
      other2 = create_audio(bitrate: 224, channels: 1)
      assert downgrader.highest?(file)
      assert_not downgrader.highest?(other1)
      assert_not downgrader.highest?(other2)
    end

    def downgrader
      @downgrader ||= Downgrade::Downgrader.new(action)
    end

    def action
      downgrade_actions(:default_mp3_1)
    end

    def create_audio(attrs)
      AudioFile.create!(attrs.reverse_merge(
                          broadcast: broadcasts(:g9s_juni),
                          path: "dummy-#{rand(9_999_999_999)}",
                          codec: 'mp3',
                          bitrate: 320,
                          channels: 2
                        ))
    end

  end
end
