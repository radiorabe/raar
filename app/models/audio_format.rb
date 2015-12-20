
class AudioFormat

  attr_reader :codec, :bitrate, :channels

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

end
