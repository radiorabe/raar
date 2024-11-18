# frozen_string_literal: true

module UserStampable

  extend ActiveSupport::Concern

  included do
    belongs_to :creator, optional: true, class_name: 'User'
    belongs_to :updater, optional: true, class_name: 'User'

    before_save :set_user_stamps
  end

  private

  def set_user_stamps
    return unless User.current

    self.creator = User.current if new_record?
    self.updater = User.current
  end

end
