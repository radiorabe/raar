# frozen_string_literal: true

module Import
  module Recording
    module File

      # These recordings have the following filename structure:
      # mp3rec-05-5-20170203-090000-3600-sec-der_morgen.wav.mp3
      class Mp3Rec < SelfContained

        self.lossy = true
        self.pending_glob = "*#{DIGIT_GLOB * 8}-#{DIGIT_GLOB * 6}-#{DIGIT_GLOB * 4}-sec-*.mp3"

        def started_at
          @started_at ||= Time.zone.parse(filename_parts[1].tr('-', ' '))
        end

        def duration
          @duration ||= filename_parts[2].to_i.seconds
        end

        def show_name
          @show_name ||= filename_parts[3]
        end

        private

        def filename_parts
          basename.match(/\-(\d{8}\-\d{4})\d{2}\-(\d{4})-sec-(.+)\.\w+.mp3$/)
        end

      end
    end
  end
end
