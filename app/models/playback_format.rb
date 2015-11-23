# == Schema Information
#
# Table name: playback_formats
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  description  :text
#  audio_format :string           not null
#  bitrate      :integer          not null
#  channels     :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class PlaybackFormat < ActiveRecord::Base

  has_many :audio_files, dependent: :nullify

  validates :name, uniqueness: true
  validates :name, :audio_format, :bitrate, :channels, presence: true
  validates :bitrate, :channels,
            numericality: { only_integer: true, greater_than: 0, allow_blank: true }

end
