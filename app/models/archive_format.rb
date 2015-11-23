# == Schema Information
#
# Table name: archive_formats
#
#  id                 :integer          not null, primary key
#  profile_id         :integer          not null
#  audio_format       :string           not null
#  initial_bitrate    :integer          not null
#  initial_channels   :integer          not null
#  max_public_bitrate :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class ArchiveFormat < ActiveRecord::Base

  belongs_to :profile

  has_many :downgrade_actions, dependent: :destroy
  has_many :audio_files, dependent: :restrict_with_error

  validates :audio_format, :inital_bitrate, :initial_channels, presence: true
  validates :audio_format, uniqueness: { scope: :profile_id }
  validates :initial_bitrate, :intial_channels, :max_public_bitrate,
            numericality: { only_integer: true, greater_than: 0, allow_blank: true }

end
