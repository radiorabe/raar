# == Schema Information
#
# Table name: playback_formats
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :text
#  codec       :string           not null
#  bitrate     :integer          not null
#  channels    :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PlaybackFormat < ActiveRecord::Base

  include WithAudioFormat

  has_many :audio_files, dependent: :nullify

  composed_of_audio_format

  validates :name,
            presence: true,
            uniqueness: true,
            format: { with: /\A[a-z0-9_]*\z/, message: :identifier_format }
  validates :audio_format, :bitrate, :channels, presence: true

  def to_s
    name
  end

end
