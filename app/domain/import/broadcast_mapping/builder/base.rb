module Import
  class BroadcastMapping
    module Builder

      # Based on a list of recording files, determine the corresponding broadcasts
      # and create a broadcast mapping object for each broadcast, containing the
      # corresponding recordings.
      class Base

        attr_reader :recordings

        def initialize(recordings)
          check_intervals(recordings)
          @recordings = recordings.sort_by(&:started_at)
        end

        def run
          build_mappings.each { |m| add_corresponding_recordings(m) }
        end

        private

        def build_mappings
          fail(NotImplementedError)
        end

        def check_intervals(recordings)
          recordings.group_by(&:started_at).each do |time, variants|
            durations = variants.collect(&:duration).uniq
            unless durations.size == 1
              fail(ArgumentError,
                   "Recordings at #{time} must all have the same durations: #{durations.inspect}.")
            end
          end
        end

        def add_corresponding_recordings(mapping)
          recordings.each do |r|
            mapping.add_if_overlapping(r)
          end
        end

      end

    end
  end
end
