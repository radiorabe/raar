module UserStampable

  extend ActiveSupport::Concern

  included do
    belongs_to :creator, optional: true, class_name: 'User' if column_names.include?('creator_id')
    belongs_to :updater, optional: true, class_name: 'User' if column_names.include?('updater_id')

    before_save :set_user_stamps
  end

  private

  def set_user_stamps
    return unless User.current

    self.creator = User.current if new_record? && respond_to?(:creator=)
    self.updater = User.current if respond_to?(:updater=)
  end

end
