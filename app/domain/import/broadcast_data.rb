module Import
  # A simple data holder for a single broadcast.
  class BroadcastData

    attr_accessor :show_name, :show_description, :label, :details,
                  :people, :started_at, :finished_at, :recordings,
                  :best_recordings

    def initialize
      @recordings = []
      @best_recordings = []
    end

    def show
      @show ||= fetch_show
    end

    def broadcast
      @broadcast ||= fetch_broadcast
    end

    def profile
      show.profile
    end

    def imported?
      broadcast.persisted?
    end

    def persist!
      Broadcast.transaction do
        show.save!
        broadcast.save!
        broadcast.audio_files.each(&:save!)
      end
    end

    def duration
      finished_at - started_at
    end

    def add_overlapping(recording)
      if overlaps?(recording)
        recordings << recording
        recording.broadcasts_data << self
      end
    end

    # Do the assigned recordings cover the entire duration of the broadcast?
    def complete?
      finish = started_at
      recordings.sort_by(&:started_at).all? do |r|
        adjacent = r.started_at <= finish
        finish = r.finished_at
        adjacent
      end && finish >= finished_at
    end

    private

    def overlaps?(recording)
      recording.datetime < finished_at &&
        recording.finished_at > started_at
    end

    def fetch_show
      Show.where(name: show_name).first_or_initialize.tap do |show|
        show.details = show_description
        show.profile ||= Profile.default
      end
    end

    def fetch_broadcast
      show.broadcasts
        .where(started_at: started_at, finished_at: finished_at)
        .first_or_initialize.tap do |bc|
        bc.label = label
        bc.people = people
        bc.details = details
      end
    end

  end
end
