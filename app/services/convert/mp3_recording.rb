module Convert
  class Mp3Recording < Recording

    self.extension = 'mp3'

    def init_values
      # mp3rec-05-5-20170203-080000-3600-sec-der_morgen.wav.mp3
      parts = File.basename(path).match(/\-(\d{8})\-(\d{4})\d{2}\-(\d{4})-sec-(.+)\.\w+.mp3$/)
      @started_at = Time.zone.parse(parts[1] + ' ' + parts[2])
      @duration = parts[3].to_i.seconds
      @show_name = parts[4]
    end

  end
end
