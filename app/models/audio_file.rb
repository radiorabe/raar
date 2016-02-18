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
      entry = at(timestamp).find_by(playback_format_id: playback_format.id)
      return entry if entry

      where('(bitrate = ? AND channels <= ?) OR bitrate < ?',
            playback_format.bitrate,
            playback_format.channels,
            playback_format.bitrate)
        .best_at(timestamp, playback_format.codec)
    end

    def only_public
      joins(broadcast: { show: { profile: :archive_formats } })
        .where('archive_formats.codec = audio_files.codec')
        .where('archive_formats.max_public_bitrate IS NULL OR ' \
               'archive_formats.max_public_bitrate >= audio_files.bitrate')
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

  def public?
    ArchiveFormat
      .joins(profile: { shows: :broadcasts })
      .where(broadcasts: { id: broadcast_id })
      .where(archive_formats: { codec: codec })
      .where('archive_formats.max_public_bitrate IS NULL OR ' \
             'archive_formats.max_public_bitrate >= ?', bitrate)
      .exists?
  end

  def to_s
    path
  end

end
