# == Schema Information
#
# Table name: shows
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  details    :text
#  profile_id :integer          not null
#
class Show < ApplicationRecord

  belongs_to :profile

  has_many :broadcasts, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_validation :set_default_profile_id

  scope :list, -> { order('LOWER(shows.name)') }

  def to_s
    name
  end

  def profile
    super || Profile.default
  end

  private

  def set_default_profile_id
    self.profile_id ||= Profile.default.id
  end

end
