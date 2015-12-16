require 'open3'

class AudioGenerator

  def create_silent_files
    AudioFile.find_each do |f|
      unless File.exists?(f.absolute_path)
        FileUtils.mkdir_p(File.dirname(f.absolute_path))
        create_silent_file(f.audio_format, f.bitrate, f.absolute_path)
      end
    end
  end

  def create_silent_file(audio_format, bitrate, path, duration = 3)
    cmd = "ffmpeg -y -f lavfi -i anullsrc=r=44100:cl=stereo -t #{duration} " \
          "-acodec #{audio_format} -v error "
    cmd += "-b:a #{bitrate}k " if bitrate
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
