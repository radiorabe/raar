# == Schema Information
#
# Table name: shows
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  details    :text
#  profile_id :integer          not null
#
class Show < ActiveRecord::Base

  belongs_to :profile

  has_many :broadcasts, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

end
