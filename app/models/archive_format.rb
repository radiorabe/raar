# == Schema Information
#
# Table name: archive_formats
#
#  id                 :integer          not null, primary key
#  profile_id         :integer          not null
#  codec              :string           not null
#  initial_bitrate    :integer          not null
#  initial_channels   :integer          not null
#  max_public_bitrate :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class ArchiveFormat < ActiveRecord::Base

  include WithAudioFormat

  belongs_to :profile

  has_many :downgrade_actions, dependent: :destroy

  composed_of_audio_format(:initial_bitrate, :initial_channels)

  validates :codec, :initial_bitrate, :initial_channels, presence: true
  validates :codec, uniqueness: { scope: :profile_id }
  validates :max_public_bitrate,
            numericality: { only_integer: true, greater_or_equal_to: 0, allow_blank: true }
  validate :assert_codec_is_unchanged, if: :codec_changed?, on: :update

  scope :list, -> { order(:codec) }

  private

  def assert_codec_is_unchanged
    errors.add(:codec, :must_not_change)
  end

end
