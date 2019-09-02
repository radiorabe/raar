# frozen_string_literal: true

module Swaggerable

  extend ActiveSupport::Concern

  included do
    include Swagger::Blocks

    include_missing(Swagger::Blocks::Nodes::OperationNode, OperationMethods)
  end

  module ClassMethods

    def include_missing(parent, mod)
      parent.send(:include, mod) unless parent.ancestors.include?(mod)
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
            key '$ref', URI.encode_www_form_component(data_class)
          end
        end
      end
    end

    def response_entity(data_class, status = 200)
      response status do
        key :description, 'successfull operation'
        schema do
          property :data do
            key '$ref', URI.encode_www_form_component(data_class)
          end
        end
      end
    end

    def response_entities(data_class, status = 200)
      response status do
        key :description, 'successfull operation'
        schema do
          property :data, type: :array do
            items '$ref' => URI.encode_www_form_component(data_class)
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
