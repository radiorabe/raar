module Import
  # A simple data holder for a single broadcast.
  class BroadcastMapping

    attr_reader :show, :broadcast, :recordings

    delegate :started_at, :finished_at, :duration,
             to: :broadcast, allow_nil: true

    def initialize
      @recordings = []
    end

    def assign_show_attrs(attrs = {})
      @show = fetch_show(attrs)
    end

    def assign_broadcast_attrs(attrs = {})
      @broadcast = fetch_broadcast(attrs)
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

    def add_if_overlapping(recording)
      if overlaps?(recording)
        recordings << recording
        recording.broadcasts_mappings << self
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

    def fetch_show(attrs = {})
      Show.where(name: attrs.fetch(:name)).first_or_initialize.tap do |show|
        show.attributes = attrs
        show.profile ||= Profile.default
      end
    end

    def fetch_broadcast(attrs = {})
      show.broadcasts
        .where(started_at: attrs.fetch(:started_at), finished_at: attrs.fetch(:finished_at))
        .first_or_initialize
        .tap { |bc| bc.attributes = attrs }
    end

  end
end
