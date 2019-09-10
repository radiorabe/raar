# frozen_string_literal: true

module AudioEncoding
  class Flac < Base

    self.bitrates = [1]

    self.channels = [1, 2]

    self.file_extension = 'flac'

    self.mime_type = 'audio/flac'

  end
end
