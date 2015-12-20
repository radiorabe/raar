module AudioEncoding
  class Base

    class_attribute :bitrates, :channels, :file_extension

    class << self

      def codec
        name.demodulize.underscore
      end

    end

  end
end
