module Stats
  class Base

    attr_reader :date_range

    class << self
      def for(year, month = nil)
        new(date_range_for(year, month))
      end

      private

      def date_range_for(year, month = nil)
        Date.new(year.to_i, (month || 1).to_i, 1)..Date.new(year.to_i, (month || 12).to_i, -1)
      end
    end

    def initialize(date_range)
      @date_range = date_range
    end

    private

    def tracks
      Track.within(date_range.first, date_range.last).joins(:broadcast)
    end

    def sort_counts(counts)
      Hash[counts.sort_by { |key, value| [-value, key] }]
    end

  end
end
