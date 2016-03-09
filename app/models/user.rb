# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  username           :string           not null
#  first_name         :string
#  last_name          :string
#  groups             :string
#  api_key            :string
#  api_key_expires_at :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class User < ActiveRecord::Base

  has_secure_token :api_key

  validates :username, presence: true, uniqueness: true

  scope :list, -> { order(:last_name, :first_name, :username) }

  class << self

    def with_api_key(key)
      return if key.blank?

      where('api_key_expires_at IS NULL OR api_key_expires_at > ?', Time.zone.now)
        .find_by_api_key(key)
    end

    def from_remote(username, groups, first_name, last_name)
      return if username.blank?

      User.where(username: username).first_or_initialize.tap do |user|
        user.groups = groups
        user.first_name = first_name
        user.last_name = last_name
        user.reset_api_key_expires_at
        user.save!
      end
    end

  end

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
