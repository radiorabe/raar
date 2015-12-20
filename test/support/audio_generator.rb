require 'open3'

class AudioGenerator

  def create_silent_files
    AudioFile.find_each do |f|
      unless File.exists?(f.absolute_path)
        FileUtils.mkdir_p(File.dirname(f.absolute_path))
        create_silent_file(f.audio_format, f.absolute_path)
      end
    end
  end

  def create_silent_file(audio_format, path, duration = 3)
    cmd = "ffmpeg -y -f lavfi -i anullsrc=r=44100:cl=stereo -t #{duration} " \
          "-acodec #{audio_format.codec} -v error "
    cmd += "-b:a #{audio_format.bitrate}k " if audio_format.bitrate
    cmd += path
    Open3.popen3(cmd) do |i, o, e, t|
      i.close
      o.gets
      errors = e.gets
      puts errors if errors.present?
      t.value
    end
  end

end
