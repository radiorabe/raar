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

  include UserStampable
  CODE_LENGTH = 6

  attr_readonly :code

  validates :expires_at, presence: true

  before_validation :generate_code, on: :create

  scope :list, -> { order(expires_at: :desc) }
  scope :expired, -> { where(expires_at: ...Time.zone.today) }

  private

  def generate_code
    self.code = SecureRandom.base58(CODE_LENGTH)
    generate_code if AccessCode.exists?(code: code)
  end

end
