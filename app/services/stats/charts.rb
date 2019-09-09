# frozen_string_literal: true

module Stats
  class Charts < Base

    attr_reader :show

    class << self
      def for(year, month = nil, show = nil)
        new(date_range_for(year, month), show)
      end
    end

    def initialize(date_range, show = nil)
      super(date_range)
      @show = show
    end

    def track_counts
      @track_counts ||= sort_counts(tracks.group(:artist, :title).count)
    end

    def artist_combo_counts
      @artist_combo_counts ||= sort_counts(tracks.group(:artist).count)
    end

    def single_artist_counts
      @single_artist_counts ||=
        sort_counts(
          artist_combo_counts.each_with_object(Hash.new(0)) do |(combo, count), hash|
            combo.split(',').map(&:strip).each do |artist|
              hash[artist] += count
            end
          end
        )
    end

    def to_csv(hash)
      require 'csv'
      CSV.generate do |csv|
        hash.each do |values|
          csv << values.flatten
        end
      end
    end

    private

    def tracks
      if show
        super.where(broadcasts: { show_id: show.id })
      else
        super
      end
    end

  end

end
