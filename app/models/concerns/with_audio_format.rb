# Common methods for models containing audio format information such as bitrate and channel.
module WithAudioFormat
  extend ActiveSupport::Concern

  def audio_format_class
    AudioFormat.get(audio_format)
  end

  # Methods for validating the audio format attributes.
  module ClassMethods

    def validate_audio_format(bitrate_attr = :bitrate, channels_attr = :channels)
      validates :audio_format, inclusion: AudioFormat.list.map(&:key)

      validates bitrate_attr, channels_attr,
                numericality: { only_integer: true, greater_than: 0, allow_blank: true }
      validate_bitrate(bitrate_attr)
      validate_channels(channels_attr)
    end

    private

    def validate_bitrate(bitrate_attr)
      validates bitrate_attr,
                inclusion: { in: -> (e) { e.audio_format_class.try(:bitrates) || [] },
                             allow_blank: true }
    end

    def validate_channels(channels_attr)
      validates channels_attr,
                inclusion: { in: -> (e) { e.audio_format_class.try(:channels) || [] },
                             allow_blank: true }
    end

  end
end
