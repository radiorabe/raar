# frozen_string_literal: true

module Import
  module Recording
    module File

      mattr_writer :klass

      def self.klass
        @@klass ||= const_get(ENV['RECORDING_FILE'].presence || 'Iso8601')
      end

      def self.new(path)
        klass.new(path)
      end

    end
  end
end
