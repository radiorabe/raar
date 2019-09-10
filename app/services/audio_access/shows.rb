# frozen_string_literal: true

module AudioAccess
  class Shows < Base

    private

    def with_archive_format
      ::Show.joins(profile: :archive_formats)
    end

  end
end
