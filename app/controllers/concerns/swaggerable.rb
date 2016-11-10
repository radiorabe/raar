module Swaggerable
  extend ActiveSupport::Concern

  included do
    include Swagger::Blocks

    include_missing(Swagger::Blocks::OperationNode, OperationMethods)
  end

  module ClassMethods

    def include_missing(parent, mod)
      parent.send(:include, mod) unless parent.ancestors.include?(mod)
    end

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
            parameter p.reverse_merge(
              in: :query,
              required: false,
              type: :string
            )
          end

          parameter name: 'page[number]',
                    in: :query,
                    description: "The page number of the #{model_name} list.",
                    required: false,
                    type: :integer

          parameter name: 'page[size]',
                    in: :query,
                    description: "Maximum number of #{model_name_plural} that are returned " \
                                 'per page. Defaults to 50, maximum is 500.',
                    required: false,
                    type: :integer

          parameter name: 'sort',
                    in: :query,
                    description: 'Name of the sort field, optionally prefixed with a `-` for ' \
                                 'descending order.',
                    required: false,
                    type: :string

          response_entities(data_class)

          security_infos(tags_read)
        end

        operation :post do
          key :description, "Creates a new #{model_name}."
          key :tags, tags_write

          path_parameters(prefix_parameters)
          parameter_attrs(model_name, 'create', data_class)

          response_entity(data_class, 201)
          response_unprocessable

          security_infos(tags_write)
        end
      end

      swagger_path("#{route_prefix}/#{route_key}/{id}") do
        operation :get do
          key :description, "Returns a single #{model_name}."
          key :tags, tags_read

          path_parameters(prefix_parameters)
          parameter_id(model_name, 'fetch')

          response_entity(data_class)

          security_infos(tags_read)
        end

        operation :patch do
          key :description, "Updates an existing #{model_name}."
          key :tags, tags_write

          path_parameters(prefix_parameters)
          parameter_id(model_name, 'update')
          parameter_attrs(model_name, 'update', data_class)

          response_entity(data_class)
          response_unprocessable

          security_infos(tags_write)
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

          security_infos(tags_write)
        end
      end
    end

  end

  module OperationMethods

    def path_parameters(list)
      list.each do |p|
        parameter p.merge(in: :path, required: true)
      end
    end

    def parameter_id(model_name, action)
      parameter name: :id,
                in: :path,
                description: "ID of the #{model_name} to #{action}.",
                required: true,
                type: :integer
    end

    def parameter_attrs(model_name, action, data_class)
      parameter name: :body,
                in: :body,
                description: "Attributes defining the #{model_name} to #{action}.",
                required: true do
        schema do
          property :data do
            key '$ref', data_class
          end
        end
      end
    end

    def security_infos(tags)
      return unless tags.include?(:admin)
      security http_token: []
      security api_token: []
    end

    def response_entity(data_class, status = 200)
      response status do
        key :description, 'successfull operation'
        schema do
          property :data do
            key '$ref', data_class
          end
        end
      end
    end

    def response_entities(data_class, status = 200)
      response status do
        key :description, 'successfull operation'
        schema do
          property :data, type: :array do
            items '$ref' => data_class
          end
        end
      end
    end

    def response_unprocessable
      response 422 do
        key '$ref', '#/responses/unprocessable_entity'
      end
    end
  end

end
