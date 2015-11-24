require 'open3'

class AudioGenerator
  def create_silent_files
    AudioFile.includes(:archive_format).each do |f|
      unless File.exists?(f.full_path)
        FileUtils.mkdir_p(File.dirname(f.full_path))
        cmd = "ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t 3 " \
              "-b:a #{f.bitrate}k -acodec #{f.archive_format.audio_format} #{f.full_path}"
        _, _, _, wait_thr = Open3.popen3(cmd)
        wait_thr.value
      end
    end
  end
end
