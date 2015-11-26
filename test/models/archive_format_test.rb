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

require 'test_helper'

class ArchiveFormatTest < ActiveSupport::TestCase
  test "all fixtures valid" do
     ArchiveFormat.all.each do |e|
       assert_valid e
     end
  end
end
