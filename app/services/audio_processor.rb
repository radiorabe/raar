# frozen_string_literal: true

# Interface for audio processors.
module AudioProcessor

  mattr_writer :klass

  def self.klass
    @@klass ||= const_get(ENV['AUDIO_PROCESSOR'].presence || 'Ffmpeg')
  end

  def self.new(file)
    klass.new(file)
  end

end
