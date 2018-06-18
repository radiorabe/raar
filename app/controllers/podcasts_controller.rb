class PodcastsController < ApplicationController

  NUMBER_OF_BROADCASTS = 20

  def show
    # TODO: auth
    builder = PodcastBuilder.new(current_user, show_model, audio_files)
    render xml: builder.to_xml
  end

  private

  def show_model
    @show_model ||= Show.find(params[:show_id])
  end

  def playback_format
    @playback_format ||= PlaybackFormat.find_by!(name: params[:playback_format],
                                                 codec: detect_codec)
  end

  def detect_codec
    AudioEncoding.for_extension!(params[:format]).codec
  end

  def audio_files
    AudioFile
      .with_playback_format(playback_format)
      .includes(:broadcast)
      .references(:broadcast)
      .where(broadcasts: { show_id: show_model.id })
      .order('broadcasts.started_at DESC')
      .limit(NUMBER_OF_BROADCASTS)
  end

end
