# == Schema Information
#
# Table name: broadcasts
#
#  id          :integer          not null, primary key
#  show_id     :integer          not null
#  label       :string           not null
#  started_at  :datetime         not null
#  finished_at :datetime         not null
#  people      :string
#  details     :text
#
class Broadcast < ActiveRecord::Base

  belongs_to :show

  has_many :audio_files, dependent: :restrict_with_error

  validates :label, :started_at, :finished_at, presence: true
  validates :started_at, :finished_at, uniqueness: true

end
