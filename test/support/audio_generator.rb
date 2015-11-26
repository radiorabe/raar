require 'open3'

class AudioGenerator
  def create_silent_files
    AudioFile.includes(:archive_format).each do |f|
      unless File.exists?(f.full_path)
        FileUtils.mkdir_p(File.dirname(f.full_path))
        create_silent_audio_file(f)
      end
    end
  end

  private

  def create_silent_audio_file(f)
    cmd = "ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t 3 " \
          "-b:a #{f.bitrate}k -acodec #{f.archive_format.audio_format} " \
          "-v error #{f.full_path}"
    i, o, e, wait_thr = Open3.popen3(cmd)
    o.gets
    errors = e.gets
    puts errors if errors.present?
    [i, o, e].each(&:close)
    wait_thr.value
  end
end
