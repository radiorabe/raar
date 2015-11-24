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

  belongs_to :broadcast
  belongs_to :archive_format
  belongs_to :playback_format, optional: true

  validates :path, :bitrate, :channels, presence: true
  validates :path, uniqueness: true
  validates :bitrate, :channels,
            numericality: { only_integer: true, greater_than: 0, allow_blank: true }

  def full_path
    File.join(Rails.application.secrets.archive_home, path)
  end

  def to_s
    path
  end

end
