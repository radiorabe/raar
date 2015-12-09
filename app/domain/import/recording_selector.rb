module Import
  module RecordingSelector

    mattr_accessor :klass

    def self.new(recordings)
      klass.new(recordings)
    end

  end
end
