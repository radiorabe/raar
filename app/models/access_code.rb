# frozen_string_literal: true

# == Schema Information
#
# Table name: access_codes
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  expires_at :date
#  created_at :datetime
#  creator_id :integer
#

class AccessCode < ApplicationRecord

  CODE_LENGTH = 6

  attr_readonly :code

  belongs_to :creator, optional: true, class_name: 'User'

  validates :expires_at, presence: true

  before_validation :generate_code, on: :create
  before_save :set_user_stamps

  scope :list, -> { order(expires_at: :desc) }
  scope :expired, -> { where(expires_at: ...Time.zone.today) }

  private

  def generate_code
    self.code = SecureRandom.base58(CODE_LENGTH)
    generate_code if AccessCode.exists?(code: code)
  end

  def set_user_stamps
    return unless User.current

    self.creator = User.current if new_record?
  end

end
