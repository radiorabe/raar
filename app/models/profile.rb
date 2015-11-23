# == Schema Information
#
# Table name: profiles
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :text
#  default     :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Profile < ActiveRecord::Base

  has_many :shows, dependent: :restrict_with_error
  has_many :archive_formats, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :default, inclusion: [true, false]

end
