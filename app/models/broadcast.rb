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

  include UserStampable

  belongs_to :show

  has_many :audio_files, dependent: :restrict_with_error

  validates :label, :started_at, :finished_at, presence: true
  validates :started_at, :finished_at, uniqueness: true

  before_validation :set_show_label_if_empty

  scope :list, -> { order('broadcasts.started_at') }

  class << self
    def at(timestamp)
      where('broadcasts.started_at <= ? AND broadcasts.finished_at > ?', timestamp, timestamp)
    end

    def within(start, finish)
      where('broadcasts.finished_at > ? AND broadcasts.started_at < ?', start, finish)
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

end
