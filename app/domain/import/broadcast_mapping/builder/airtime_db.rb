module Import
  class BroadcastMapping
    module Builder
      # Builds BroadcastMappings based on the show instances found in the airtime database
      # at the time of the given recordings.
      class AirtimeDb < Base

        private

        def build_mappings
          show_instances.collect do |instance|
            build_broadcast_mapping(instance)
          end
        end

        def show_instances
          @show_instances ||= recordings.present? ? fetch_show_instances : []
        end

        def build_broadcast_mapping(instance)
          Import::BroadcastMapping.new.tap do |mapping|
            assign_show(mapping, instance)
            assign_broadcast(mapping, instance)
          end
        end

        def assign_show(mapping, instance)
          mapping.assign_show(
            name: instance.show.name.strip,
            details: instance.show.description)
        end

        def assign_broadcast(mapping, instance)
          mapping.assign_broadcast(
            label: instance.show.name.strip,
            details: instance.show.description,
            started_at: instance.starts,
            finished_at: instance.ends,
            people: '')
        end

        def fetch_show_instances
          Airtime::ShowInstance
            .where('starts < ? AND ends > ?',
                   recordings.last.finished_at,
                   recordings.first.started_at)
            .order(:starts)
            .includes(:show)
        end

      end
    end
  end
end
