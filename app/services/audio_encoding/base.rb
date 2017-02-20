module AudioEncoding
  class Base

    class_attribute :bitrates, :channels, :file_extension, :mime_type

    class << self

      def codec
        name.demodulize.underscore
      end

      def lossless?
        bitrates.size == 1
      end

    end

  end
end
