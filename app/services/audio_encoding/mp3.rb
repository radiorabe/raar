module AudioEncoding
  class Mp3 < Base

    self.bitrates = [32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320]

    self.channels = [1, 2]

    self.file_extension = 'mp3'

    self.mime_type = 'audio/mpeg'

  end
end
