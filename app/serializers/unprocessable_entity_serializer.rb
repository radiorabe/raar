# frozen_string_literal: true

class UnprocessableEntitySerializer

  include Swagger::Blocks

  swagger_schema('UnprocessableEntity') do
    property :source do
      property :pointer, type: :string
    end
    property :details, type: :string
  end

end
