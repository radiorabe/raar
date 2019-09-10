# frozen_string_literal: true

module Import
  module Recording
    module File
      class SelfContained < Base

        attr_reader :show_name

        def sequel?(other)
          other &&
            show_name == other.show_name &&
            other.started_at - finished_at < DURATION_TOLERANCE.seconds
        end

      end
    end
  end
end
