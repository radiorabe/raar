require 'test_helper'

class ImportTest < ActiveSupport::TestCase

  include RecordingHelper
  include AirtimeHelper

  self.use_transactional_tests = false

  # Travis has ffmpeg 0.8.17, which reports "Unknown input format: 'lavfi'"
  unless ENV['TRAVIS'] || true # skip for now
    test 'imports recordings as broadcasts' do
      Time.zone.stubs(today: Time.local(2013, 6, 19))
      build_recording_files
      build_airtime_entries

      assert_difference('Show.count', 1) do
        assert_difference('Broadcast.count', 2) do
          assert_difference('AudioFile.count', 6) do
            system Rails.root.join('bin', 'import').to_s
          end
        end
      end

      assert_equal 6, Dir.glob("tmp/archive/2013/09/19/*.mp3").size
    end
  end

  private

  def build_recording_files
    touch('2013-06-10T090000+0200_060_imported.mp3') # old imported
    touch('2013-06-19T080000+0200_060_imported.mp3')
    touch('2013-06-19T090000+0200_060_imported.mp3')
    f1 = file('2013-06-10T100000+0200_060.mp3') # old unimported
    f2 = file('2013-06-19T100000+0200_060.mp3')
    f3 = file('2013-06-19T110000+0200_060.mp3')
    f4 = file('2013-06-19T120000+0200_060.mp3')
    [f1, f2, f3, f4].each do |f|
      AudioGenerator.new.create_silent_file(AudioFormat.new('mp3', 320, 2), f, 60 * 60)
    end
  end

  def build_airtime_entries
    morgen = Airtime::Show.create!(name: 'Morgen')
    morgen.show_instances.create!(starts: Time.local(2013, 6, 18, 8),
                                  ends: Time.local(2013, 6, 18, 11),
                                  created: Time.zone.now)
    morgen.show_instances.create!(starts: Time.local(2013, 6, 19, 8),
                                  ends: Time.local(2013, 6, 19, 11),
                                  created: Time.zone.now)
    info = Airtime::Show.create!(name: 'Info')
    info.show_instances.create!(starts: Time.local(2013, 6, 19, 11),
                                ends: Time.local(2013, 6, 19, 11, 30),
                                created: Time.zone.now)
    info.show_instances.create!(starts: Time.local(2013, 6, 20, 11),
                                ends: Time.local(2013, 6, 20, 11, 30),
                                created: Time.zone.now)
    mittag = Airtime::Show.create!(name: 'Mittag')
    mittag.show_instances.create!(starts: Time.local(2013, 6, 19, 11, 30),
                                  ends: Time.local(2013, 6, 19, 13),
                                  created: Time.zone.now)
  end

end
