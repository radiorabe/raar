# frozen_string_literal: true

module Import
  class BroadcastMapping
    # Maps broadcasts to a list of recording files.
    # .klass defines the actual strategy to be used for that
    module Builder

      mattr_writer :klass

      def self.klass
        @@klass ||= const_get(ENV['BROADCAST_MAPPING_BUILDER'].presence || 'AirtimeDb')
      end

      def self.new(recordings)
        klass.new(recordings)
      end

    end
  end
end
