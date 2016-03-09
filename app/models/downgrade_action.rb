# == Schema Information
#
# Table name: downgrade_actions
#
#  id                :integer          not null, primary key
#  archive_format_id :integer          not null
#  months            :integer          not null
#  bitrate           :integer
#  channels          :integer
#
class DowngradeAction < ActiveRecord::Base

  include WithAudioFormat

  belongs_to :archive_format

  composed_of_audio_format

  validates :months,
            presence: true,
            uniqueness: { scope: :archive_format_id },
            numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :channels, presence: { if: :bitrate }

  delegate :codec, to: :archive_format

  scope :list, -> { order(:months) }

end
