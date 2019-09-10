# frozen_string_literal: true

module Auth
  class Base

    attr_reader :request

    def initialize(request)
      @request = request
    end

    def fetch_user
      # implement in subclass
    end

  end
end
