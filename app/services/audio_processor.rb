# frozen_string_literal: true

# Interface for audio processors.
module AudioProcessor

  COMMON_FLAC_FRAME_SIZE = 1152

  class FailingFrameSizeError < StandardError
  end

  mattr_writer :klass

  def self.klass
    @@klass ||= const_get(ENV['AUDIO_PROCESSOR'].presence || 'Ffmpeg')
  end

  def self.new(file)
    klass.new(file)
  end

end
