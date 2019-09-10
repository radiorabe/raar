# frozen_string_literal: true

class StatusSerializer < ApplicationSerializer

  swagger_schema('Status') do
    property :id, type: :string
    property :type, type: :string
    property :attributes do
      property :api, type: :boolean
      property :database, type: :boolean
      property :file_system, type: :boolean
    end
  end

  attributes :id, :api, :database, :file_system

end
