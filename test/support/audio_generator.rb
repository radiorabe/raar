# frozen_string_literal: true

require 'open3'

class AudioGenerator

  def silent_files_for_audio_files
    AudioFile.find_each do |f|
      unless File.exist?(f.absolute_path)
        FileUtils.mkdir_p(File.dirname(f.absolute_path))
        silent_file(f.audio_format, f.absolute_path)
      end
    end
  end

  def silent_file(audio_format, path, duration = 3)
    return if File.exist?(path)

    FileUtils.cp(silent_source_file(audio_format, duration), path)
  end

  def silent_source_file(audio_format, duration = 3)
    file = File.join(temp_dir,
                     "silence_#{duration}s_#{audio_format.bitrate}k." \
                     "#{audio_format.file_extension}")
    unless File.exist?(file)
      FileUtils.mkdir_p(temp_dir)
      create_silent_file(audio_format, file, duration)
    end
    file
  end

  def create_silent_file(audio_format, path, duration = 3)
    cmd = "ffmpeg -y -f lavfi -i anullsrc=r=44100:cl=stereo -t #{duration} " \
          "-acodec #{audio_format.codec} -v error "
    cmd += "-b:a #{audio_format.bitrate}k " if audio_format.bitrate
    cmd += "-metadata title=\"Title 'yeah'!\" " \
           '-metadata artist="Ärtist Ünknöwn" ' \
           '-metadata album="Albüm" ' \
           '-metadata date="2016" '
    cmd += path
    Rails.logger.debug { "Create silent file: #{cmd}" }
    Open3.popen3(cmd) do |i, o, e, t|
      i.close
      o.gets
      errors = e.gets
      puts errors if errors.present?
      t.value
    end
  end

  def temp_dir
    @temp_dir ||= Rails.root.join('tmp', 'test', 'audio', $TEST_WORKER.to_s) # rubocop:disable Style/GlobalVars
  end

end
