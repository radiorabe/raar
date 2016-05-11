# == Schema Information
#
# Table name: profiles
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :text
#  default     :boolean          default(FALSE), not null
#  created_at  :datetime
#  updated_at  :datetime
#

class Profile < ActiveRecord::Base

  has_many :shows, dependent: :restrict_with_error
  has_many :archive_formats, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :default, inclusion: [true, false]
  validate :assert_exactly_one_default_profile_exists

  # If we set a new default, remove flag from other instances.
  after_save :clear_defaults, if: :default

  scope :list, -> { order('LOWER(name)') }

  class << self

    def default
      find_by(default: true)
    end

  end

  def to_s
    name
  end

  private

  def clear_defaults
    Profile.where('id <> ?', id).update_all(default: false)
  end

  def assert_exactly_one_default_profile_exists
    errors.add(:default, :must_exist) if default_changed? && !default
  end

end
