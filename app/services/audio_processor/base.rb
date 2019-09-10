# frozen_string_literal: true

module AudioProcessor
  # Base class for processing audio files.
  class Base

    attr_reader :file

    def initialize(file)
      @file = file
    end

    def transcode(_new_path, _audio_format, _tags = {})
      raise(NotImplementedError)
    end

    def trim(_new_path, _start, _duration)
      raise(NotImplementedError)
    end

    def concat(_new_path, _others)
      raise(NotImplementedError)
    end

    def tag(_tags)
      raise(NotImplementedError)
    end

    def bitrate
      raise(NotImplementedError)
    end

    def channels
      raise(NotImplementedError)
    end

    def codec
      raise(NotImplementedError)
    end

    def duration
      raise(NotImplementedError)
    end

  end
end
