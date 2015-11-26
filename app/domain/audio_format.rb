# Base module for the available audio formats, such as MP3, Ogg or Flac.
module AudioFormat
  def self.get(key)
    AudioFormat::Base.subclasses.detect { |c| c.key == key }
  end

  def self.list
    AudioFormat::Base.subclasses
  end
end

require_relative 'audio_format/mp3'
