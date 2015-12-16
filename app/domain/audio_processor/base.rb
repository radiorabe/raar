module AudioProcessor
  # Base class for processing audio files.
  class Base

    attr_reader :file

    def initialize(file)
      @file = file
    end

    def transcode(_new_path, _bitrate, _channels, _codec = codec)
      fail(NotImplementedError)
    end

    def split(_new_path, _start, _duration)
      fail(NotImplementedError)
    end

    def concat(_others, _new_path)
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

  end
end
