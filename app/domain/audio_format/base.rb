module AudioFormat
  class Base

    class_attribute :bitrates, :channels, :file_extension

    class << self

      def key
        name.demodulize.underscore
      end

    end

  end
end
