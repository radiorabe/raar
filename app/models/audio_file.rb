# == Schema Information
#
# Table name: audio_files
#
#  id                 :integer          not null, primary key
#  broadcast_id       :integer          not null
#  path               :string           not null
#  bitrate            :integer          not null
#  channels           :integer          not null
#  archive_format_id  :integer          not null
#  playback_format_id :integer
#
class AudioFile < ActiveRecord::Base

  include WithAudioFormat

  belongs_to :broadcast
  belongs_to :archive_format
  belongs_to :playback_format, optional: true

  validates :path, :bitrate, :channels, presence: true
  validates :path, uniqueness: true
  validate_audio_format

  delegate :audio_format, to: :archive_format

  def absolute_path
    FileStore::Layout.absolute_path(path)
  end

  def to_s
    path
  end

end
