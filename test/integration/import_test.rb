require 'test_helper'

class ImportTest < ActiveSupport::TestCase

  include RecordingHelper
  include AirtimeHelper

  teardown :clear_archive_dir

  self.use_transactional_tests = false

  # Travis has ffmpeg 0.8.17, which reports "Unknown input format: 'lavfi'"
  unless ENV['TRAVIS']
    test 'imports recordings as broadcasts' do
      Time.zone.stubs(today: Time.local(2013, 6, 19),
                      now: Time.local(2013, 6, 19, 11))
      # build dummy recordings and broadcasts with a duration of two minutes                
      build_recording_files
      build_airtime_entries

      ExceptionNotifier
        .expects(:notify_exception)
        .with(Import::Recording::UnimportedWarning.new(Import::Recording.new(@f1)))

      assert_difference('Show.count', 1) do
        assert_difference('Broadcast.count', 2) do
          assert_difference('AudioFile.count', 6) do
            Import.run
          end
        end
      end

      archive_mp3s = File.join(FileStore::Structure.home, '2013', '06', '19', '*.mp3')
      assert_equal 6, Dir.glob(archive_mp3s).size
    end
  end

  private

  def build_recording_files
    touch('2013-06-10T090000+0200_060_imported.mp3') # old imported
    touch('2013-06-19T080000+0200_060_imported.mp3')
    touch('2013-06-19T090000+0200_060_imported.mp3')
    @f1 = file('2013-06-10T100000+0200_002.mp3') # old unimported
    @f2 = file('2013-06-19T100600+0200_002.mp3')
    @f3 = file('2013-06-19T100800+0200_002.mp3')
    @f4 = file('2013-06-19T101000+0200_002.mp3')
    AudioGenerator.new.create_silent_file(AudioFormat.new('mp3', 320, 2), @f1, 120)
    [@f2, @f3, @f4].each { |f| FileUtils.cp(@f1, f) }
  end

  def build_airtime_entries
    morgen = Airtime::Show.create!(name: 'Morgen')
    morgen.show_instances.create!(starts: Time.local(2013, 6, 18, 8),
                                  ends: Time.local(2013, 6, 18, 11),
                                  created: Time.zone.now)
    morgen.show_instances.create!(starts: Time.local(2013, 6, 19, 10),
                                  ends: Time.local(2013, 6, 19, 10, 8),
                                  created: Time.zone.now)
    info = Airtime::Show.create!(name: 'Info')
    info.show_instances.create!(starts: Time.local(2013, 6, 19, 10, 8),
                                ends: Time.local(2013, 6, 19, 10, 9),
                                created: Time.zone.now)
    info.show_instances.create!(starts: Time.local(2013, 6, 20, 11),
                                ends: Time.local(2013, 6, 20, 11, 30),
                                created: Time.zone.now)
    mittag = Airtime::Show.create!(name: 'Mittag')
    mittag.show_instances.create!(starts: Time.local(2013, 6, 19, 10, 9),
                                  ends: Time.local(2013, 6, 19, 10, 12),
                                  created: Time.zone.now)
  end

  def clear_archive_dir
    FileUtils.rm_rf(FileStore::Structure.home)
  end

end