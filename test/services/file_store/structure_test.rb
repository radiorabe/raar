# frozen_string_literal: true

require 'test_helper'

module FileStore
  class StructureTest < ActiveSupport::TestCase

    test 'relative path is utc' do
      b1 = Broadcast.new(show: shows(:g9s),
                         label: 'Gschächnüt $$$chlimmers  ',
                         started_at: Time.zone.local(2012, 5, 12, 20),
                         finished_at: Time.zone.local(2012, 5, 12, 22))
      file = AudioFile.new(broadcast: b1,
                           codec: 'mp3',
                           bitrate: 224,
                           channels: 2)
      path = FileStore::Structure.new(file).relative_path
      assert_equal '2012/05/12/2012-05-12T200000+0200_120_gschachnut_chlimmers.224k_2.mp3', path
    end

  end
end
