# frozen_string_literal: true

# Base module for the available audio formats, such as MP3, Ogg or Flac.
module AudioEncoding

  def self.[](codec)
    registry[codec]
  end

  def self.fetch(codec)
    self[codec] || raise(ArgumentError, "Unknown codec #{codec}")
  end

  def self.for_extension(file_extension)
    list.detect { |e| e.file_extension == file_extension.to_s.strip }
  end

  def self.list
    registry.values
  end

  def self.registry
    @@registry ||= AudioEncoding::Base.subclasses.index_by(&:codec)
  end

end

require_dependency 'audio_encoding/mp3'
require_dependency 'audio_encoding/flac'
