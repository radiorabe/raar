module Import
  module Recording
    module File
      class SelfContained < Base

        class_attribute :extension

        attr_reader :show_name

        class << self

          def pending_glob
            "*.#{extension}"
          end

        end

        def sequel?(other)
          other &&
            show_name == other.show_name &&
            other.started_at - finished_at < DURATION_TOLERANCE.seconds
        end

      end
    end
  end
end
