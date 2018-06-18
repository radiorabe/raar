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

class AudioFile < ApplicationRecord

  include WithAudioFormat

  belongs_to :broadcast
  belongs_to :playback_format, optional: true

  composed_of_audio_format

  validates :path, :bitrate, :channels, presence: true
  validates :path, uniqueness: true
  validates :playback_format_id, uniqueness: { scope: :broadcast_id, allow_nil: true }

  scope :list, -> { order('codec, bitrate DESC, channels DESC') }

  class << self

    def at(timestamp)
      joins(:broadcast).merge(Broadcast.at(timestamp))
    end

    # Get the best quality file for the given timestamp and codec.
    def best_at(timestamp, codec)
      at(timestamp).where(codec: codec).order('bitrate DESC, channels DESC').first
    end

    # Get file for the given playback_format. If it does not exist,
    # return the next lower quality file with the same codec.
    def playback_format_at(timestamp, playback_format)
      at(timestamp).with_playback_format(playback_format).first
    end

    def with_playback_format(playback_format)
      where('playback_format_id = ? OR (bitrate = ? AND channels <= ?) OR bitrate < ?',
            playback_format.id,
            playback_format.bitrate,
            playback_format.channels,
            playback_format.bitrate)
        .where(codec: playback_format.codec)
        .group(:broadcast_id)
        .having('bitrate + channels = MAX(bitrate + channels)')
    end

  end

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
