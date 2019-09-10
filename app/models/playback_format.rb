# frozen_string_literal: true

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
#  created_at  :datetime
#  updated_at  :datetime
#  creator_id  :integer
#  updater_id  :integer
#

class PlaybackFormat < ApplicationRecord

  include WithAudioFormat
  include UserStampable

  has_many :audio_files, dependent: :nullify

  composed_of_audio_format

  validates :name,
            presence: true,
            uniqueness: { scope: :codec },
            format: { with: /\A[a-z0-9_]*\z/, message: :identifier_format }
  validates :codec, :bitrate, :channels, presence: true

  scope :list, -> { order(:name, :codec) }

  def to_s
    "#{name}.#{codec}"
  end

end
