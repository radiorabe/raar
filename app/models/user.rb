# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  username           :string           not null
#  first_name         :string
#  last_name          :string
#  groups             :string
#  api_key            :string           not null
#  api_key_expires_at :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  creator_id         :integer
#  updater_id         :integer
#

class User < ApplicationRecord

  include UserStampable

  thread_cattr_accessor :current

  attr_accessor :access_code

  has_secure_token :api_key

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  scope :list, -> { order(:last_name, :first_name, :username) }

  def to_s
    username
  end

  def admin?
    (listify(groups) & listify(Rails.application.secrets.admin_groups)).present?
  end

  def groups=(value)
    value = value.join(',') if value.is_a?(Array)
    super(value)
  end

  def group_list
    listify(groups)
  end

  def api_token
    "#{id}$#{api_key}" if api_key?
  end

  def regenerate_api_key!
    self.api_key = self.class.generate_unique_secure_token
    reset_api_key_expires_at
    save!
  end

  def reset_api_key_expires_at
    days = Rails.application.secrets.days_to_expire_api_key
    self.api_key_expires_at = days.present? ? Time.zone.today + days.to_i.days : nil
  end

  private

  def listify(string)
    string.to_s.split(/[,;]/).collect(&:strip).compact
  end

end
