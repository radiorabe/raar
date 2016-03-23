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
      validate_encoding_attr(bitrate_attr, :bitrates)
      validate_encoding_attr(channels_attr, :channels)
    end

    private

    def validate_encoding_attr(attr, encoding_field)
      validates attr,
                inclusion: {
                  in: -> (e) { e.audio_encoding.send(encoding_field) },
                  if: :audio_encoding,
                  allow_blank: true }
    end

  end
end
