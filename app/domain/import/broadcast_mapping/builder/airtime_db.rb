module Import
  class BroadcastMapping

    module Builder
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
            assign_show_attrs(mapping, instance)
            assign_broadcast_attrs(mapping, instance)
          end
        end

        def assign_show_attrs(mapping, instance)
          mapping.assign_show_attrs(
            name: instance.show.name,
            details: instance.show.description)
        end

        def assign_broadcast_attrs(mapping, instance)
          # TODO: time zone conversion necessary?
          mapping.assign_broadcast_attrs(
            label: instance.show.name,
            details: instance.description,
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
