# frozen_string_literal: true

module Admin
  module CrudSwag

    extend ActiveSupport::Concern

    module ClassMethods

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def crud_swagger_paths(options = {})
        route_prefix = options[:route_prefix]
        route_key = options[:route_key] || model_class.model_name.route_key
        model_name = options[:model_name] ||
                     model_class.model_name.singular.humanize(capitalize: false)
        model_name_plural = options[:model_name_plural] || model_name.pluralize
        tags = [model_identifier] + Array(options[:tags])
        tags_read = tags + Array(options[:tags_read])
        tags_write = tags + Array(options[:tags_write])
        data_class = options.fetch(:data_class)
        prefix_parameters = Array(options[:prefix_parameters])

        swagger_path("#{route_prefix}/#{route_key}") do
          operation :get do
            key :description, "Returns a list of #{model_name_plural}."
            key :tags, tags_read

            path_parameters(prefix_parameters)

            Array(options[:query_params]).each do |p|
              if p.is_a?(Hash)
                parameter p.reverse_merge(
                  in: :query,
                  required: false,
                  type: :string
                )
              else
                parameter p
              end
            end

            parameter :page_number
            parameter :page_size
            parameter :sort

            response_entities(data_class)

            security jwt_token: []
          end

          operation :post do
            key :description, "Creates a new #{model_name}."
            key :tags, tags_write

            path_parameters(prefix_parameters)
            parameter_attrs(model_name, 'create', data_class)

            response_entity(data_class, 201)
            response_unprocessable

            security jwt_token: []
          end
        end

        swagger_path("#{route_prefix}/#{route_key}/{id}") do
          operation :get do
            key :description, "Returns a single #{model_name}."
            key :tags, tags_read

            path_parameters(prefix_parameters)
            parameter_id(model_name, 'fetch')

            response_entity(data_class)

            security jwt_token: []
          end

          operation :patch do
            key :description, "Updates an existing #{model_name}."
            key :tags, tags_write

            path_parameters(prefix_parameters)
            parameter_id(model_name, 'update')
            parameter_attrs(model_name, 'update', data_class)

            response_entity(data_class)
            response_unprocessable

            security jwt_token: []
          end

          operation :delete do
            key :description, "Deletes an existing #{model_name}."
            key :tags, tags_write

            path_parameters(prefix_parameters)
            parameter_id(model_name, 'delete')

            response 204 do
              key :description, 'successfull operation'
            end

            response_unprocessable

            security jwt_token: []
          end
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    end

  end
end
