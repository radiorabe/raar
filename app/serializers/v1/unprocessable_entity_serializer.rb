module V1
  class UnprocessableEntitySerializer

    include Swagger::Blocks

    swagger_schema('V1::UnprocessableEntity') do
      # TODO: fix
      property :errors, type: :string
    end

  end
end
