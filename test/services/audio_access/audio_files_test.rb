require 'test_helper'

class AudioAccess::AudioFilesTest < ActiveSupport::TestCase

  test 'filter for user nil contains only file with same or smaller bitrate' do
    assert_equal audio_files(:info_april_high, :info_april_low),
                 files(:info_april, nil)
  end

  test 'filter for user User.new contains only file with same or smaller bitrate' do
    assert_equal audio_files(:info_april_best, :info_april_high, :info_april_low),
                 files(:info_april, User.new)
  end

  test 'filter for user nil contains no files if bitrates are all higher' do
    assert_equal [],
                 files(:g9s_mai, nil)
  end

  test 'filter for user new contains only files with smaller bitrate' do
    assert_equal [audio_files(:g9s_mai_low)],
                 files(:g9s_mai, User.new)
  end

  test 'filter for user member contains only files with smaller bitrate' do
    assert_equal [audio_files(:g9s_mai_low)],
                 files(:g9s_mai, users(:member))
  end

  test 'filter for user speedee contains only files with smaller bitrate' do
    assert_equal audio_files(:g9s_mai_high, :g9s_mai_low),
                 files(:g9s_mai, users(:speedee))
  end

  test 'filter for user admin contains all files' do
    assert_equal audio_files(:g9s_mai_high, :g9s_mai_low),
                 files(:g9s_mai, users(:admin))
  end

  test 'filter for user nil contains no files without archive format' do
    archive_formats(:default_mp3).destroy
    assert_equal [],
                 files(:g9s_mai, nil)
  end

  test 'filter for user speedee contains no files without archive format' do
    archive_formats(:default_mp3).destroy
    assert_equal [],
                 files(:g9s_mai, users(:speedee))
  end

  test 'filter for user admin contains all files without archive format' do
    archive_formats(:default_mp3).destroy
    assert_equal audio_files(:g9s_mai_high, :g9s_mai_low),
                 files(:g9s_mai, users(:admin))
  end

  test '#access_permitted?(nil) is true if bitrate is smaller than max_public_bitrate' do
    assert access_permitted?(:info_april_low, nil)
  end

  test '#access_permitted?(nil) is true if bitrate is same as max_public_bitrate' do
    assert access_permitted?(:info_april_high, nil)
  end

  test '#access_permitted?(nil) is false if bitrate is higher than max_public_bitrate' do
    assert !access_permitted?(:info_april_best, nil)
  end

  test '#access_permitted?(new) is true if bitrate is smaller than max_logged_in_bitrate' do
    archive_formats(:important_mp3).update!(max_logged_in_bitrate: 256)
    assert access_permitted?(:info_april_low, User.new)
  end

  test '#access_permitted?(new) is true if bitrate is same as max_logged_in_bitrate' do
    archive_formats(:important_mp3).update!(max_logged_in_bitrate: 192)
    assert access_permitted?(:info_april_high, User.new)
  end

  test '#access_permitted?(new) is true if max_logged_in_bitrate is nil' do
    archive_formats(:important_mp3).update!(max_logged_in_bitrate: nil)
    assert access_permitted?(:info_april_best, User.new)
  end

  test '#access_permitted?(new) is false if bitrate is higher than max_logged_in_bitrate' do
    archive_formats(:important_mp3).update!(max_public_bitrate: 96, max_logged_in_bitrate: 96)
    assert !access_permitted?(:info_april_best, User.new)
  end

  test '#access_permitted?(member) is true if bitrate is smaller than max_logged_in_bitrate' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: 256)
    assert access_permitted?(:g9s_mai_high, users(:member))
  end

  test '#access_permitted?(member) is true if bitrate is same as max_logged_in_bitrate' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: 192)
    assert access_permitted?(:g9s_mai_high, users(:member))
  end

  test '#access_permitted?(member) is true if max_logged_in_bitrate is nil' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: nil, max_priviledged_bitrate: nil)
    assert access_permitted?(:g9s_mai_high, users(:member))
  end

  test '#access_permitted?(member) is false if bitrate is higher than max_logged_in_bitrate but same as max_priviledged_bitrate' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: 96, max_priviledged_bitrate: 192)
    assert !access_permitted?(:g9s_mai_high, users(:member))
  end

  test '#access_permitted?(member) is false if bitrate is higher than max_logged_in_bitrate and max_priviledged_bitrate is nil' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: 96, max_priviledged_bitrate: nil)
    assert !access_permitted?(:g9s_mai_high, users(:member))
  end

  test '#access_permitted?(member) is false if bitrate is higher than max_logged_in_bitrate' do
    archive_formats(:default_mp3).update!(max_public_bitrate: 96, max_logged_in_bitrate: 96)
    assert !access_permitted?(:g9s_mai_high, users(:member))
  end

  test '#access_permitted?(speedee) is true if bitrate is smaller than max_priviledged_bitrate' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: 96, max_priviledged_bitrate: 320)
    assert access_permitted?(:g9s_mai_high, users(:speedee))
  end

  test '#access_permitted?(speedee) is true if bitrate is same as max_priviledged_bitrate' do
    archive_formats(:default_mp3).update!(max_priviledged_bitrate: 192)
    assert access_permitted?(:g9s_mai_high, users(:speedee))
  end

  test '#access_permitted?(speedee) is true if max_priviledged_bitrate is nil' do
    archive_formats(:default_mp3).update!(max_logged_in_bitrate: 96, max_priviledged_bitrate: nil)
    assert access_permitted?(:g9s_mai_high, users(:speedee))
  end

  test '#access_permitted?(speedee) is false if bitrate is higher than max_priviledged_bitrate' do
    archive_formats(:default_mp3).update!(max_public_bitrate: 96, max_logged_in_bitrate: 96, max_priviledged_bitrate: 96)
    assert !access_permitted?(:g9s_mai_high, users(:speedee))
  end

  test '#access_permitted?(admin) is true even if nothing is permitted' do
    archive_formats(:default_mp3).update!(max_public_bitrate: 0, max_logged_in_bitrate: 0, max_priviledged_bitrate: 0)
    assert access_permitted?(:g9s_mai_high, users(:admin))
  end

  test '#download_permitted?(nil) is true if permission is public' do
    archive_formats(:default_mp3).update!(download_permission: :public)
    assert download_permitted?(:g9s_mai_low, nil)
  end

  test '#download_permitted?(nil) is false if permission is logged_in' do
    archive_formats(:default_mp3).update!(download_permission: :logged_in)
    assert !download_permitted?(:g9s_mai_low, nil)
  end

  test '#download_permitted?(nil) is false if permission is nil' do
    archive_formats(:default_mp3).update!(download_permission: nil)
    assert !download_permitted?(:g9s_mai_low, nil)
  end

  test '#download_permitted?(new) is true if permission is public' do
    archive_formats(:default_mp3).update!(download_permission: :public)
    assert download_permitted?(:g9s_mai_high, User.new)
  end

  test '#download_permitted?(new) is true if permission is logged_in' do
    archive_formats(:default_mp3).update!(download_permission: :logged_in)
    assert download_permitted?(:g9s_mai_high, User.new)
  end

  test '#download_permitted?(new) is false if permission is priviledged' do
    archive_formats(:default_mp3).update!(download_permission: :priviledged)
    assert !download_permitted?(:g9s_mai_high, User.new)
  end

  test '#download_permitted?(member) is true if permission is logged_in' do
    archive_formats(:default_mp3).update!(download_permission: :logged_in)
    assert download_permitted?(:g9s_mai_high, users(:member))
  end

  test '#download_permitted?(member) is false if permission is priviledged' do
    archive_formats(:default_mp3).update!(download_permission: :priviledged)
    assert !download_permitted?(:g9s_mai_high, users(:member))
  end

  test '#download_permitted?(speedee) is true if permission is logged_in' do
    archive_formats(:default_mp3).update!(download_permission: :logged_in)
    assert download_permitted?(:g9s_mai_high, users(:speedee))
  end

  test '#download_permitted?(speedee) is true if permission is priviledged' do
    archive_formats(:default_mp3).update!(download_permission: :priviledged)
    assert download_permitted?(:g9s_mai_high, users(:speedee))
  end

  test '#download_permitted?(speedee) is false if permission is admin' do
    archive_formats(:default_mp3).update!(download_permission: :admin)
    assert !download_permitted?(:g9s_mai_high, users(:speedee))
  end

  test '#download_permitted?(admin) is true if permission is admin' do
    archive_formats(:default_mp3).update!(download_permission: :admin)
    assert download_permitted?(:g9s_mai_high, users(:admin))
  end

  test '#download_permitted?(admin) is true if permission is nil' do
    archive_formats(:default_mp3).update!(download_permission: nil)
    assert download_permitted?(:g9s_mai_high, users(:admin))
  end

  test '#download_permitted?(admin) is true if archive_format is nil' do
    archive_formats(:default_mp3).destroy
    assert download_permitted?(:g9s_mai_high, users(:admin))
  end

  private

  def files(broadcast, user)
    AudioAccess::AudioFiles.new(user).filter(broadcasts(broadcast).audio_files.list)
  end

  def download_permitted?(file, user)
    AudioAccess::AudioFiles.new(user).download_permitted?(audio_files(file))
  end

  def access_permitted?(file, user)
    AudioAccess::AudioFiles.new(user).access_permitted?(audio_files(file))
  end

end
