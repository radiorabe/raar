# == Schema Information
#
# Table name: audio_files
#
#  id                 :integer          not null, primary key
#  broadcast_id       :integer          not null
#  path               :string           not null
#  codec              :string           not null
#  bitrate            :integer          not null
#  channels           :integer          not null
#  playback_format_id :integer
#  created_at         :datetime         not null
#

require 'test_helper'

class AudioFileTest < ActiveSupport::TestCase

  test 'all fixtures valid' do
    AudioFile.all.each do |e|
      assert_valid e
    end
  end

  test '.at just at start returns files' do
    file = audio_files(:g9s_mai_high)
    assert_equal 2, AudioFile.at(file.broadcast.started_at).size
  end

  test '.at just before finish returns files' do
    file = audio_files(:g9s_mai_high)
    assert_equal 2, AudioFile.at(file.broadcast.finished_at - 1.second).size
  end

  test '.at just before start is empty' do
    file = audio_files(:klangbecken_mai1_best)
    assert_equal [], AudioFile.at(file.broadcast.started_at - 1.second)
  end

  test '.at just at finish is empty' do
    file = audio_files(:g9s_mai_high)
    assert_equal [], AudioFile.at(file.broadcast.finished_at)
  end

  test '.best_at returns best bitrate for codec' do
    file = audio_files(:g9s_mai_high)
    assert_equal file, AudioFile.best_at(file.broadcast.started_at + 1.hour, file.codec)
  end

  test '.playback_format_at returns corresponding file' do
    file = audio_files(:g9s_mai_low)
    assert_equal file,
                 AudioFile.playback_format_at(file.broadcast.started_at, file.playback_format)
  end

  test '.playback_format_at without matching format returns next lower file' do
    file = audio_files(:g9s_mai_low)
    audio_files(:g9s_mai_high).destroy!
    assert_equal file,
                 AudioFile.playback_format_at(file.broadcast.started_at, playback_formats(:high))
  end

  test '.playback_format_at without matching format and no lower file returns nil' do
    file = audio_files(:g9s_mai_low)
    file.destroy!
    assert_nil AudioFile.playback_format_at(file.broadcast.started_at, playback_formats(:low))
  end

  test '.for_user(nil) contains only file with same or smaller bitrate' do
    assert_equal audio_files(:info_april_high, :info_april_low),
                 broadcasts(:info_april).audio_files.for_user(nil).list
  end

  test '.for_user(User.new) contains only file with same or smaller bitrate' do
    assert_equal audio_files(:info_april_best, :info_april_high, :info_april_low),
                 broadcasts(:info_april).audio_files.for_user(User.new).list
  end

  test '.for_user(nil) contains no files if bitrates are all higher' do
    assert_equal [],
                 broadcasts(:g9s_mai).audio_files.for_user(nil).list
  end

  test '.for_user(new) contains only files with smaller bitrate' do
    assert_equal [audio_files(:g9s_mai_low)],
                 broadcasts(:g9s_mai).audio_files.for_user(User.new).list
  end

  test '.for_user(member) contains only files with smaller bitrate' do
    assert_equal [audio_files(:g9s_mai_low)],
                 broadcasts(:g9s_mai).audio_files.for_user(users(:member)).list
  end

  test '.for_user(speedee) contains only files with smaller bitrate' do
    assert_equal audio_files(:g9s_mai_high, :g9s_mai_low),
                 broadcasts(:g9s_mai).audio_files.for_user(users(:speedee)).list
  end

  test '.for_user(admin) contains all files' do
    assert_equal audio_files(:g9s_mai_high, :g9s_mai_low),
                 broadcasts(:g9s_mai).audio_files.for_user(users(:admin)).list
  end

  test '.for_user(nil) contains no files without archive format' do
    archive_formats(:default_mp3).destroy
    assert_equal [],
                 broadcasts(:g9s_mai).audio_files.for_user(nil).list
  end

  test '.for_user(speedee) contains no files without archive format' do
    archive_formats(:default_mp3).destroy
    assert_equal [],
                 broadcasts(:g9s_mai).audio_files.for_user(users(:speedee)).list
  end

  test '.for_user(admin) contains all files without archive format' do
    archive_formats(:default_mp3).destroy
    assert_equal audio_files(:g9s_mai_high, :g9s_mai_low),
                 broadcasts(:g9s_mai).audio_files.for_user(users(:admin)).list
  end

  test '#access_permitted?(nil) is true if bitrate is smaller than max_public_bitrate' do
    assert audio_files(:info_april_low).access_permitted?(nil)
  end

  test '#access_permitted?(nil) is true if bitrate is same as max_public_bitrate' do
    assert audio_files(:info_april_high).access_permitted?(nil)
  end

  test '#access_permitted?(nil) is false if bitrate is higher than max_public_bitrate' do
    assert !audio_files(:info_april_best).access_permitted?(nil)
  end

  test '#access_permitted?(new) is true if bitrate is smaller than max_logged_in_bitrate' do
    archive_formats(:important_mp3).update!(max_logged_in_bitrate: 256)
    assert audio_files(:info_april_low).access_permitted?(User.new)
  end

  test '#access_permitted?(new) is true if bitrate is same as max_logged_in_bitrate' do
    archive_formats(:important_mp3).update!(max_logged_in_bitrate: 192)
    assert audio_files(:info_april_high).access_permitted?(User.new)
  end

  test '#access_permitted?(new) is true if max_logged_in_bitrate is nil' do
    archive_formats(:important_mp3).update!(max_logged_in_bitrate: nil)
    assert audio_files(:info_april_best).access_permitted?(User.new)
  end

  test '#access_permitted?(new) is false if bitrate is higher than max_logged_in_bitrate' do
    archive_formats(:important_mp3).update!(max_public_bitrate: 96, max_logged_in_bitrate: 96)
    assert !audio_files(:info_april_best).access_permitted?(User.new)
  end

  test '#access_permitted?(member) is true if bitrate is smaller than max_logged_in_bitrate' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: 256)
    assert audio_files(:g9s_mai_high).access_permitted?(users(:member))
  end

  test '#access_permitted?(member) is true if bitrate is same as max_logged_in_bitrate' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: 192)
    assert audio_files(:g9s_mai_high).access_permitted?(users(:member))
  end

  test '#access_permitted?(member) is true if max_logged_in_bitrate is nil' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: nil, max_priviledged_bitrate: nil)
    assert audio_files(:g9s_mai_high).access_permitted?(users(:member))
  end

  test '#access_permitted?(member) is false if bitrate is higher than max_logged_in_bitrate but same as max_priviledged_bitrate' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: 96, max_priviledged_bitrate: 192)
    assert !audio_files(:g9s_mai_high).access_permitted?(users(:member))
  end

  test '#access_permitted?(member) is false if bitrate is higher than max_logged_in_bitrate and max_priviledged_bitrate is nil' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: 96, max_priviledged_bitrate: nil)
    assert !audio_files(:g9s_mai_high).access_permitted?(users(:member))
  end

  test '#access_permitted?(member) is false if bitrate is higher than max_logged_in_bitrate' do
    archive_formats(:default_mp3).update!(max_public_bitrate: 96, max_logged_in_bitrate: 96)
    assert !audio_files(:g9s_mai_high).access_permitted?(users(:member))
  end

  test '#access_permitted?(speedee) is true if bitrate is smaller than max_priviledged_bitrate' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: 96, max_priviledged_bitrate: 320)
    assert audio_files(:g9s_mai_high).access_permitted?(users(:speedee))
  end

  test '#access_permitted?(speedee) is true if bitrate is same as max_priviledged_bitrate' do
    archive_formats(:default_mp3).update!(max_priviledged_bitrate: 192)
    assert audio_files(:g9s_mai_high).access_permitted?(users(:speedee))
  end

  test '#access_permitted?(speedee) is true if max_priviledged_bitrate is nil' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: 96, max_priviledged_bitrate: nil)
    assert audio_files(:g9s_mai_high).access_permitted?(users(:speedee))
  end

  test '#access_permitted?(speedee) is false if bitrate is higher than max_priviledged_bitrate' do
    archive_formats(:default_mp3).update!(max_public_bitrate: 96, max_logged_in_bitrate: 96, max_priviledged_bitrate: 96)
    assert !audio_files(:g9s_mai_high).access_permitted?(users(:speedee))
  end

  test '#access_permitted?(admin) is true even if nothing is permitted' do
    archive_formats(:default_mp3).update!(max_public_bitrate: 0, max_logged_in_bitrate: 0, max_priviledged_bitrate: 0)
    assert audio_files(:g9s_mai_high).access_permitted?(users(:admin))
  end

  test '#download_permitted?(nil) is true if permission is public' do
    archive_formats(:default_mp3).update!(download_permission: :public)
    assert audio_files(:g9s_mai_low).download_permitted?(nil)
  end

  test '#download_permitted?(nil) is false if permission is logged_in' do
    archive_formats(:default_mp3).update!(download_permission: :logged_in)
    assert !audio_files(:g9s_mai_low).download_permitted?(nil)
  end

  test '#download_permitted?(nil) is false if permission is nil' do
    archive_formats(:default_mp3).update!(download_permission: nil)
    assert !audio_files(:g9s_mai_low).download_permitted?(nil)
  end

  test '#download_permitted?(new) is true if permission is public' do
    archive_formats(:default_mp3).update!(download_permission: :public)
    assert audio_files(:g9s_mai_high).download_permitted?(User.new)
  end

  test '#download_permitted?(new) is true if permission is logged_in' do
    archive_formats(:default_mp3).update!(download_permission: :logged_in)
    assert audio_files(:g9s_mai_high).download_permitted?(User.new)
  end

  test '#download_permitted?(new) is false if permission is priviledged' do
    archive_formats(:default_mp3).update!(download_permission: :priviledged)
    assert !audio_files(:g9s_mai_high).download_permitted?(User.new)
  end

  test '#download_permitted?(member) is true if permission is logged_in' do
    archive_formats(:default_mp3).update!(download_permission: :logged_in)
    assert audio_files(:g9s_mai_high).download_permitted?(users(:member))
  end

  test '#download_permitted?(member) is false if permission is priviledged' do
    archive_formats(:default_mp3).update!(download_permission: :priviledged)
    assert !audio_files(:g9s_mai_high).download_permitted?(users(:member))
  end

  test '#download_permitted?(speedee) is true if permission is logged_in' do
    archive_formats(:default_mp3).update!(download_permission: :logged_in)
    assert audio_files(:g9s_mai_high).download_permitted?(users(:speedee))
  end

  test '#download_permitted?(speedee) is true if permission is priviledged' do
    archive_formats(:default_mp3).update!(download_permission: :priviledged)
    assert audio_files(:g9s_mai_high).download_permitted?(users(:speedee))
  end

  test '#download_permitted?(speedee) is false if permission is admin' do
    archive_formats(:default_mp3).update!(download_permission: :admin)
    assert !audio_files(:g9s_mai_high).download_permitted?(users(:speedee))
  end

  test '#download_permitted?(admin) is true if permission is admin' do
    archive_formats(:default_mp3).update!(download_permission: :admin)
    assert audio_files(:g9s_mai_high).download_permitted?(users(:admin))
  end

  test '#download_permitted?(admin) is true if permission is nil' do
    archive_formats(:default_mp3).update!(download_permission: nil)
    assert audio_files(:g9s_mai_high).download_permitted?(users(:admin))
  end

  test '#download_permitted?(admin) is true if archive_format is nil' do
    archive_formats(:default_mp3).destroy
    assert audio_files(:g9s_mai_high).download_permitted?(users(:admin))
  end

end
