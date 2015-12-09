module Import
  # Maps broadcasts to a list of recording files.
  # .klass defines the actual strategy to be used for that
  module BroadcastMapper

    mattr_accessor :klass

    def self.new(recordings)
      klass.new(recordings)
    end

  end
end
