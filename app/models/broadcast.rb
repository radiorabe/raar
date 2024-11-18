# frozen_string_literal: true

# == Schema Information
#
# Table name: broadcasts
#
#  id          :integer          not null, primary key
#  show_id     :integer          not null
#  label       :string           not null
#  started_at  :datetime         not null
#  finished_at :datetime         not null
#  people      :string
#  details     :text
#  created_at  :datetime
#  updated_at  :datetime
#  updater_id  :integer
#

class Broadcast < ApplicationRecord

  include NonOverlappable

  belongs_to :show
  belongs_to :updater, optional: true, class_name: 'User'

  has_many :audio_files, dependent: :restrict_with_error
  has_many :tracks, dependent: :nullify

  validates :label, :started_at, :finished_at, presence: true
  validates :started_at, :finished_at, uniqueness: true

  before_validation :set_show_label_if_empty
  before_save :set_user_stamps
  after_create :assign_tracks

  scope :list, -> { order('broadcasts.started_at') }

  class << self

    def at(timestamp)
      where('broadcasts.started_at <= ? AND broadcasts.finished_at > ?', timestamp, timestamp)
    end

  end

  def to_s
    I18n.l(started_at)
  end

  # duration in seconds
  def duration
    finished_at - started_at
  end

  private

  def set_show_label_if_empty
    self.label ||= show.name if show
  end

  def assign_tracks
    Track
      .where(tracks: { started_at: started_at..finished_at })
      .update_all(broadcast_id: id)
  end

  def set_user_stamps
    return unless User.current

    self.updater = User.current
  end

end
