# frozen_string_literal: true

# == Schema Information
#
# Table name: playback_formats
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :text
#  codec       :string           not null
#  bitrate     :integer          not null
#  channels    :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#  creator_id  :integer
#  updater_id  :integer
#

require 'test_helper'

class PlaybackFormatTest < ActiveSupport::TestCase

  test 'all fixtures valid' do
    PlaybackFormat.find_each do |e|
      assert_valid e
    end
  end

  test 'name must be a valid identifier' do
    p = playback_formats(:low)
    p.name = 'Expre?'
    assert_not_valid p, :name
  end

end
