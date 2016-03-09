# Common methods for models containing audio format information such as bitrate and channel.
module WithAudioFormat
  extend ActiveSupport::Concern

  def audio_encoding
    AudioEncoding[codec]
  end

  # Methods for validating the audio format attributes.
  module ClassMethods

    def composed_of_audio_format(bitrate_attr = :bitrate, channels_attr = :channels)
      composed_of :audio_format,
                  mapping: [%w(codec codec),
                            [bitrate_attr, :bitrate],
                            [channels_attr, :channels]]

      validate_audio_format(bitrate_attr, channels_attr)
    end

    def validate_audio_format(bitrate_attr = :bitrate, channels_attr = :channels)
      validates :codec, inclusion: AudioEncoding.list.map(&:codec)

      validates bitrate_attr, channels_attr,
                numericality: { only_integer: true, greater_than: 0, allow_blank: true }
      validate_bitrate(bitrate_attr)
      validate_channels(channels_attr)
    end

    private

    def validate_bitrate(bitrate_attr)
      validates bitrate_attr,
                inclusion: { in: -> (e) { e.audio_encoding.bitrates },
                             if: :audio_encoding,
                             allow_blank: true }
    end

    def validate_channels(channels_attr)
      validates channels_attr,
                inclusion: { in: -> (e) { e.audio_encoding.channels },
                             if: :audio_encoding,
                             allow_blank: true }
    end

  end
end
