module Import
  # A simple data holder for a single broadcast.
  class BroadcastMapping

    attr_accessor :show
    attr_reader :broadcast

    delegate :started_at, :finished_at, :duration,
             to: :broadcast, allow_nil: true

    delegate :profile, to: :show, allow_nil: true

    def initialize
      @recordings = []
    end

    # Assigns a show based on the given attrs. A :name key must be included.
    def assign_show(attrs = {})
      @show = fetch_show(attrs)
    end

    # Assigns a broadcast based on the given attrs.
    # :started_at and :finished_at keys must be included.
    # This method may only be called after a show is set.
    def assign_broadcast(attrs = {})
      raise(KeyError, 'show attrs must be set beforehand') unless @show
      @broadcast = fetch_broadcast(attrs)
    end

    def to_s
      "#{show} @ #{I18n.l(broadcast.started_at)}"
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

    def recordings
      @recordings.clone
    end

    def add_recording_if_overlapping(recording)
      if overlaps?(recording)
        @recordings << recording
        recording.broadcasts_mappings << self
        true
      else
        false
      end
    end

    # Do the assigned recordings cover the entire duration of the broadcast?
    def complete?
      finish = started_at + Recording::DURATION_TOLERANCE.seconds
      @recordings.sort_by(&:started_at).all? do |r|
        adjacent = r.started_at <= finish
        finish = r.finished_at + Recording::DURATION_TOLERANCE.seconds
        adjacent
      end && finish >= finished_at
    end

    private

    def overlaps?(recording)
      recording.started_at < finished_at &&
        recording.finished_at > started_at
    end

    def fetch_show(attrs = {})
      show = Show.where('LOWER(name) = ?', attrs.fetch(:name).mb_chars.downcase).first ||
             Show.create(name: attrs.fetch(:name))
      show.details = attrs[:details] if attrs[:details].present?
      show
    end

    def fetch_broadcast(attrs = {})
      show.broadcasts
          .where(started_at: attrs.fetch(:started_at), finished_at: attrs.fetch(:finished_at))
          .first_or_initialize
          .tap { |bc| bc.attributes = attrs }
    end

  end
end
