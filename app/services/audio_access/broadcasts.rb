# frozen_string_literal: true

module AudioAccess
  class Broadcasts < Base

    private

    def with_archive_format
      ::Broadcast
        .joins(show: { profile: :archive_formats })
    end

  end
end
