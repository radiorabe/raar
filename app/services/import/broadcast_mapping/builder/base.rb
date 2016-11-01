module Import
  class BroadcastMapping
    module Builder

      # Based on a list of recording files, determine the corresponding broadcasts
      # and create a broadcast mapping object for each broadcast, containing the
      # corresponding recordings.
      class Base

        include Loggable

        attr_reader :recordings

        def initialize(recordings)
          check_intervals(recordings)
          @recordings = recordings.sort_by(&:started_at)
          @unmapped_recordings = @recordings.clone
        end

        def run
          build_mappings.each { |m| add_corresponding_recordings(m) }.tap do |_|
            warn_for_unmapped_recordings
          end
        end

        private

        def build_mappings
          raise(NotImplementedError)
        end

        def check_intervals(recordings)
          recordings.group_by(&:started_at).each do |time, variants|
            durations = variants.collect(&:duration).uniq
            unless durations.size == 1
              raise(ArgumentError,
                    "Recordings at #{time} must all have the same durations: #{durations.inspect}.")
            end
          end
        end

        def add_corresponding_recordings(mapping)
          recordings.each do |r|
            if mapping.add_recording_if_overlapping(r)
              @unmapped_recordings.delete(r)
            end
          end
        end

        def warn_for_unmapped_recordings
          if @unmapped_recordings.present?
            warn("No corresponding broadcasts found for the following recordings:\n" +
                 @unmapped_recordings.collect(&:path).join("\n"))
          end
        end

      end

    end
  end
end
