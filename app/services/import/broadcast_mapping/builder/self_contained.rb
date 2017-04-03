module Import
  class BroadcastMapping
    module Builder
      # Builds BroadcastMappings based on the information found in the given recordings.
      class SelfContained < Base

        SHOW_NAME_YAML = Rails.root.join('config', 'show_names.yml')

        private

        def build_mappings
          broadcast_recordings = []
          mappings = []
          recordings.each do |r|
            handle_recording(r, broadcast_recordings, mappings)
          end
          handle_recording(nil, broadcast_recordings, mappings)
          mappings
        end

        def handle_recording(current, broadcast_recordings, mappings)
          if broadcast_recordings.present? && !broadcast_recordings.last.sequel?(current)
            mappings << build_broadcast_mapping(broadcast_recordings)
            broadcast_recordings.clear
          end
          broadcast_recordings << current
        end

        def build_broadcast_mapping(broadcast_recordings)
          Import::BroadcastMapping.new.tap do |mapping|
            assign_show(mapping, broadcast_recordings)
            assign_broadcast(mapping, broadcast_recordings)
          end
        end

        def assign_show(mapping, broadcast_recordings)
          mapping.assign_show(
            name: fetch_show_name(broadcast_recordings.first)
          )
        end

        def assign_broadcast(mapping, broadcast_recordings)
          mapping.assign_broadcast(
            label: fetch_show_name(broadcast_recordings.first),
            started_at: broadcast_recordings.first.started_at,
            finished_at: broadcast_recordings.last.finished_at
          )
        end

        def fetch_show_name(recording)
          show_name_mapping[recording.show_name] || recording.show_name.titleize
        end

        def show_name_mapping
          @show_name_mapping ||=
            if File.exist?(SHOW_NAME_YAML)
              YAML.safe_load(File.read(SHOW_NAME_YAML))
            else
              {}
            end
        end

      end
    end
  end
end
