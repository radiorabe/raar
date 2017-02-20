module Convert
  class Recording < Import::Recording

    class_attribute :extension

    attr_reader :show_name, :started_at, :duration

    def initialize(path)
      super(path)
      init_values
    end

    def sequel?(other)
      show_name == other.show_name &&
        other.started_at - finished_at < DURATION_TOLERANCE.seconds
    end

    def mark_imported
      # no-op
    end

    def audio_encoding
      AudioEncoding.for_extension(extension)
    end

    private

    def init_values
      # set @started_at, @duration and @show_name in subclass
    end

  end
end
