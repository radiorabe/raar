module V1
  class UnprocessableEntitySerializer

    include Swagger::Blocks

    swagger_schema('V1::UnprocessableEntity') do
      property :source do
        property :pointer, type: :string
      end
      property :details, type: :string
    end

  end
end
