# == Schema Information
#
# Table name: archive_formats
#
#  id                      :integer          not null, primary key
#  profile_id              :integer          not null
#  codec                   :string           not null
#  initial_bitrate         :integer          not null
#  initial_channels        :integer          not null
#  max_public_bitrate      :integer
#  created_at              :datetime
#  updated_at              :datetime
#  download_permission     :integer
#  max_logged_in_bitrate   :integer
#  max_priviledged_bitrate :integer
#  priviledged_groups      :string
#  creator_id              :integer
#  updater_id              :integer
#

class ArchiveFormat < ApplicationRecord

  include WithAudioFormat
  include UserStampable

  attr_readonly :codec

  enum download_permission: [:public, :logged_in, :priviledged, :admin], _prefix: true

  belongs_to :profile

  has_many :downgrade_actions, dependent: :destroy

  composed_of_audio_format(:initial_bitrate, :initial_channels)

  validates :codec, :initial_bitrate, :initial_channels, presence: true
  validates :codec, uniqueness: { scope: :profile_id }
  validates :max_public_bitrate,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,  # 0 = no access
              allow_blank: true             # nil = full access
            }
  validates :max_logged_in_bitrate,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: :max_public_bitrate,
              if: :max_public_bitrate,
              allow_blank: true
            },
            absence: {
              unless: :max_public_bitrate
            }
  validates :max_priviledged_bitrate,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: :max_logged_in_bitrate,
              if: :max_logged_in_bitrate,
              allow_blank: true
            },
            absence: {
              unless: :max_logged_in_bitrate
            }
  validate :assert_codec_not_changed, on: :update

  before_save :normalize_priviledged_groups

  scope :list, -> { order(:codec) }

  def priviledged_groups=(value)
    value = value.join(',') if value.is_a?(Array)
    super(value)
  end

  def priviledged_group_list
    priviledged_groups.to_s.split(/[,;]/).collect(&:strip).compact
  end

  private

  def assert_codec_not_changed
    errors.add(:codec, :must_not_change) if codec_changed?
  end

  def normalize_priviledged_groups
    self.priviledged_groups = priviledged_group_list.join(',').presence
  end

end
