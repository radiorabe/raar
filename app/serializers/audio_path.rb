class AudioPath

  BEST_FORMAT = 'best'.freeze

  attr_reader :audio_file

  def initialize(audio_file)
    @audio_file = audio_file
  end

  def url_params
    timestamp_params.merge(
      playback_format: playback_format,
      format: file_extension
    )
  end

  def playback_format
    audio_file.playback_format.try(:name) || BEST_FORMAT
  end

  private

  def timestamp
    audio_file.broadcast.started_at
  end

  def timestamp_params
    %w[year month day hour min sec].each_with_object({}) do |key, hash|
      hash[key.to_sym] = format('%02d', timestamp.send(key))
    end
  end

  def file_extension
    audio_file.audio_format.file_extension
  end

end
