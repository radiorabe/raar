# A value object representing an audio format, consisting of codec, bitrate and channels.
class AudioFormat

  attr_reader :codec, :bitrate, :channels
  delegate :file_extension, to: :encoding

  def initialize(codec, bitrate, channels)
    @codec = codec
    @bitrate = bitrate
    @channels = channels
  end

  def encoding
    AudioEncoding.fetch(codec)
  end

  def ==(other)
    codec == other.codec &&
      bitrate == other.bitrate &&
      channels == other.channels
  end
  alias eql? ==

  def hash
    [codec, bitrate, channels].hash
  end

end
