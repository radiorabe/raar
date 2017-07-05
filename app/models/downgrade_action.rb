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
  has_one :profile, through: :archive_format

  composed_of_audio_format

  validates :months,
            presence: true,
            uniqueness: { scope: :archive_format_id },
            numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :bitrate,
            uniqueness: { scope: [:archive_format_id, :channels] },
            numericality: { less_than_or_equal_to: :initial_bitrate, allow_blank: true }
  validates :channels,
            presence: { if: :bitrate },
            numericality: { less_than_or_equal_to: :initial_channels, allow_blank: true }
  validate :assert_decreasing_actions, if: :bitrate
  validate :assert_delete_is_last, unless: :bitrate

  delegate :codec, :initial_bitrate, :initial_channels,
           to: :archive_format

  scope :list, -> { order(:months) }

  def to_s
    months
  end

  private

  def assert_decreasing_actions
    %w[bitrate channels].each do |attr|
      errors.add(attr, :must_decrease) if non_decreasing_actions(attr).exists?
    end
  end

  def non_decreasing_actions(attr)
    value = send(attr)
    scope = DowngradeAction.where(archive_format_id: archive_format_id)
                           .where("(months > ? AND #{attr} > ?) OR " \
                                  "(months < ? AND (#{attr} < ? OR #{attr} IS NULL))",
                                  months, value,
                                  months, value)
    persisted? ? scope.where.not(id: id) : scope
  end

  def assert_delete_is_last
    errors.add(:base, :delete_must_be_last) if later_actions.exists?
  end

  def later_actions
    scope = DowngradeAction.where(archive_format_id: archive_format_id)
                           .where('months > ?', months)
    persisted? ? scope.where.not(id: id) : scope
  end

end
