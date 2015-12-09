module Import
  module BroadcastMapper
    class AirtimeDb < Base

      def mapping
        show_instances.collect do |instance|
          data = build_broadcast_data(instance)
          add_corresponding_recordings(data)
          data
        end
      end

      private

      def build_broadcast_data(instance)
        BroadcastData.new.tap do |data|
          data.show_name = instance.show.name
          data.show_description = instance.show.description
          data.label = instance.show.name
          data.details = instance.description
          data.people = ''
          data.started_at = instance.starts
          data.finished_at = instance.ends
        end
      end

      def add_corresponding_recordings(data)
        recordings.each do |r|
          data.add_overlapping(r)
        end
      end

      def show_instances
        @show_instances ||= recordings.present? ? fetch_show_instances : []
      end

      def fetch_show_instances
        Airtime::ShowInstance
          .where('starts < ? AND ends > ?',
                 last_recording_end,
                 first_recording_start)
          .order(:starts)
          .includes(:show)
      end

      def first_recording_start
        intervals.keys.sort.first
      end

      def last_recording_end
        last = intervals.keys.sort.last
        intervals[last].finished_at
      end

      # TODO: probably not required to do grouping
      def intervals
        @intervals ||= recordings.group_by(&:datetime)
      end

      def check_intervals
        intervals.each do |time, recordings|
          durations = recordings.collect(&:duration).uniq
          unless durations.size == 1
            fail("Recordings at #{time} must all have the same durations: #{durations.inspect}.")
          end
        end
      end

    end
  end
end
