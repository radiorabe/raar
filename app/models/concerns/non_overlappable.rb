module NonOverlappable

  extend ActiveSupport::Concern

  included do
    validate :assert_not_overlapping
  end

  private

  def assert_not_overlapping
    scope = overlapping_scope
    scope = scope.where.not(id: id) if persisted?
    if scope.exists?
      errors.add(:started_at, :must_not_overlap)
      throw :abort
    end
  end

  def overlapping_scope
    self.class.where('started_at < ? AND finished_at > ?', finished_at, started_at)
  end

end
