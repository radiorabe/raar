# frozen_string_literal: true

# == Schema Information
#
# Table name: tracks
#
#  id           :integer          not null, primary key
#  title        :string           not null
#  artist       :string
#  started_at   :datetime         not null
#  finished_at  :datetime         not null
#  broadcast_id :integer
#

class Track < ApplicationRecord

  include NonOverlappable

  belongs_to :broadcast, optional: true

  before_save :assign_broadcast, if: :started_at_changed?

  validates :title, :started_at, :finished_at, presence: true
  validates :started_at, uniqueness: true

  scope :list, -> { order('tracks.started_at') }

  class << self
    def for_show(show_id)
      joins(:broadcast).where(broadcasts: { show_id: show_id })
    end
  end

  def to_s
    "#{I18n.l(started_at)}: #{[artist, title].compact.join(' - ')}"
  end

  # duration in seconds
  def duration
    finished_at - started_at
  end

  private

  def assign_broadcast
    self.broadcast = Broadcast.at(started_at).first
  end

end
