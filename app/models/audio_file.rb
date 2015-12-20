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

class AudioFile < ActiveRecord::Base

  include WithAudioFormat

  belongs_to :broadcast
  belongs_to :playback_format, optional: true

  composed_of_audio_format

  validates :path, :bitrate, :channels, presence: true
  validates :path, uniqueness: true

  def absolute_path
    FileStore::Structure.new(self).absolute_path
  end

  def generate_path
    self.path ||= FileStore::Structure.new(self).relative_path
  end

  def with_path
    generate_path
    self
  end

  def to_s
    path
  end

end
