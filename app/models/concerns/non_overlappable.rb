# frozen_string_literal: true

module NonOverlappable

  extend ActiveSupport::Concern

  included do
    validate :assert_not_overlapping
  end

  private

  def assert_not_overlapping
    scope = self.class.within(started_at, finished_at)
    scope = scope.where.not(id: id) if persisted?
    if scope.exists?
      errors.add(:started_at, :must_not_overlap)
      throw :abort
    end
  end

  module ClassMethods

    def within(start, finish)
      where("#{table_name}.finished_at > ? AND #{table_name}.started_at < ?", start, finish)
    end

  end

end
