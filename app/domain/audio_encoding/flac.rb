module AudioEncoding
  class Flac < Base

    self.bitrates = [1]

    self.channels = [1, 2]

    self.file_extension = 'flac'

  end
end
