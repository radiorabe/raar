# Base module for the available audio formats, such as MP3, Ogg or Flac.
module AudioEncoding

  def self.fetch(codec)
    list.detect { |c| c.codec == codec } || fail(ArgumentError, "Unknown codec #{codec}")
  end

  def self.list
    AudioEncoding::Base.subclasses
  end

end

require_relative 'audio_encoding/mp3'
