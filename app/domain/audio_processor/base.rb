module AudioProcessor
  # Base class for processing audio files.
  class Base

    attr_reader :file

    def initialize(file)
      @file = file
    end

    def transcode(_new_path, _audio_format)
      fail(NotImplementedError)
    end

    def trim(_new_path, _start, _duration)
      fail(NotImplementedError)
    end

    def concat(_new_path, _others)
      fail(NotImplementedError)
    end

    def bitrate
      fail(NotImplementedError)
    end

    def channels
      fail(NotImplementedError)
    end

    def codec
      fail(NotImplementedError)
    end

    def duration
      fail(NotImplementedError)
    end

  end
end
