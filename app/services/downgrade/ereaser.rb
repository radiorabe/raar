# frozen_string_literal: true

module Downgrade
  class Ereaser < ActionHandler

    class << self

      def actions
        DowngradeAction.where('bitrate IS NULL')
      end

    end

  end
end
