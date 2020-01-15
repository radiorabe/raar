# frozen_string_literal: true

module Import
  class BroadcastMapping
    module Builder
      # Based on a list of recording files, determine the corresponding broadcasts
      # and create a broadcast mapping object for each broadcast, containing the
      # corresponding recordings.
      class Base

        include Loggable
        DURATION_TOLERANCE = 5.minutes

        attr_reader :recordings

        def initialize(recordings)
          check_intervals(recordings)
          @recordings = recordings.sort_by(&:started_at)
        end

        def run
          return [] if recordings.blank?

          build_allover_mappings.tap do |mappings|
            mappings.each { |m| add_corresponding_recordings(m) }
          end
        end

        private

        def build_allover_mappings
          fill_gaps_with_default_show(build_mappings,
                                      recordings.first.started_at,
                                      recordings.last.finished_at)
            .compact
        end

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
            mapping.add_recording_if_overlapping(r)
          end
        end

        def fill_gaps_with_default_show(mappings, cut, fin)
          [].tap do |all|
            mappings.each do |m|
              if m.started_at > cut + DURATION_TOLERANCE
                all << handle_broadcast_gap(cut, m.started_at)
              end
              all << m
              cut = m.finished_at
            end
            all << handle_broadcast_gap(cut, fin) if fin > cut + DURATION_TOLERANCE
          end
        end

        def handle_broadcast_gap(started_at, finished_at)
          at_period = "from #{I18n.l(started_at)} to #{I18n.l(finished_at, format: :time)}"
          if default_show
            warn("Creating default broadcast #{at_period}.")
            build_default_mapping(started_at, finished_at)
          else
            warn("No broadcast found #{at_period}.")
            nil
          end
        end

        def build_default_mapping(started_at, finished_at)
          Import::BroadcastMapping.new.tap do |mapping|
            mapping.show = default_show
            mapping.assign_broadcast(
              label: default_show.name,
              started_at: started_at,
              finished_at: finished_at
            )
          end
        end

        def default_show
          @default_show ||= begin
            id = Rails.application.secrets.import_default_show_id
            id.present? && Show.find(id)
          end
        end

      end
    end
  end
end
