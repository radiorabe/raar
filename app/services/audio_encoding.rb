# Base module for the available audio formats, such as MP3, Ogg or Flac.
module AudioEncoding

  def self.[](codec)
    list.detect { |c| c.codec == codec.to_s.strip }
  end

  def self.fetch(codec)
    self[codec] || raise(ArgumentError, "Unknown codec #{codec}")
  end

  def self.for_extension(file_extension)
    list.detect { |e| e.file_extension == file_extension.to_s.strip }
  end

  def self.for_extension!(file_extension)
    for_extension(file_extension).tap do |encoding|
      raise ActionController::UnknownFormat unless encoding
    end
  end

  def self.list
    AudioEncoding::Base.subclasses
  end

end

require_dependency 'audio_encoding/mp3'
require_dependency 'audio_encoding/flac'
