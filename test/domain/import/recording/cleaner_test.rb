require 'test_helper'

class Import::Recording::CleanerTest < ActiveSupport::TestCase

  include RecordingHelper

  test '#clear_old_imported removes old and keeps newer' do
    newer = file("#{1.day.ago.to_s(:iso8601).tr(':', '')}_120_imported.mp3")
    older = file("#{2.days.ago.to_s(:iso8601).tr(':', '')}_020_imported.mp3")
    unimported = file("#{2.days.ago.to_s(:iso8601).tr(':', '')}_020.mp3")
    [newer, older, unimported].each { |f| FileUtils.touch(f) }

    cleaner.clear_old_imported
    assert File.exists?(newer)
    assert !File.exists?(older)
    assert File.exists?(unimported)
  end

  test '#warn_for_old_unimported issues warning' do
    newer = file("#{1.day.ago.to_s(:iso8601).tr(':', '')}_120.mp3")
    older = file("#{2.days.ago.to_s(:iso8601).tr(':', '')}_020.mp3")
    imported = file("#{2.days.ago.to_s(:iso8601).tr(':', '')}_020_imported.mp3")
    [newer, older, imported].each { |f| FileUtils.touch(f) }

    ExceptionNotifier.expects(:notify_exception).once
    cleaner.warn_for_old_unimported
  end

  private

  def cleaner
    @cleaner ||= Import::Recording::Cleaner.new
  end

end
