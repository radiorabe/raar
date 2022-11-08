# frozen_string_literal: true

require 'test_helper'

class Import::Recording::CleanerTest < ActiveSupport::TestCase

  include RecordingHelper

  test '#clear_old_imported removes old and keeps newer' do
    newer = touch("#{1.day.ago.to_fs(:iso8601).tr(':', '')}_120_imported.mp3")
    older = touch("#{2.days.ago.to_fs(:iso8601).tr(':', '')}_020_imported.mp3")
    unimported = touch("#{2.days.ago.to_fs(:iso8601).tr(':', '')}_020.mp3")

    cleaner.clear_old_imported
    assert File.exist?(newer)
    assert_not File.exist?(older)
    assert File.exist?(unimported)
  end

  test '#warn_for_old_unimported issues warning' do
    newer = touch("#{1.day.ago.to_fs(:iso8601).tr(':', '')}_120.mp3")
    older = touch("#{2.days.ago.to_fs(:iso8601).tr(':', '')}_020.mp3")
    imported = touch("#{2.days.ago.to_fs(:iso8601).tr(':', '')}_020_imported.mp3")

    ExceptionNotifier.expects(:notify_exception).once
    cleaner.warn_for_old_unimported
  end

  private

  def cleaner
    @cleaner ||= Import::Recording::Cleaner.new
  end

end
