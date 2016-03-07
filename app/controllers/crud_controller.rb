# A generic controller to display, create, update and destroy entries of a certain model class.
class CrudController < ListController

  class_attribute :permitted_attrs

  # POST /users
  def create
    if entry.save
      render json: entry, status: :created, location: entry_url, serializer: model_serializer
    else
      render json: entry.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if entry.update(model_params)
      render json: entry, serializer: model_serializer
    else
      render json: entry.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    if entry.destroy
      head 204
    else
      render json: entry.errors, status: :unprocessable_entity
    end
  end

  private

  def fetch_entry
    params[:id] ? super : model_scope.new(model_params)
  end

  def entry_url
    prefix = self.class.name.deconstantize.underscore.tr('/', '_')
    send("#{prefix}_#{entry.class.model_name.singular_route_key}_url", entry)
  end

  # Only allow a trusted parameter "white list" through.
  def model_params
    params.require('data').require('attributes').permit(permitted_attrs)
  end

  class << self

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def crud_swagger_paths(options = {})
      route_prefix = options[:route_prefix]
      route_key = options[:route_key] || model_class.model_name.route_key
      model_name = options[:model_name] || model_class.model_name.human
      model_name_plural = options[:model_name_plural] || model_class.model_name.human.pluralize
      tags = [model_identifier] + Array(options[:tags])
      data_class = options.fetch(:data_class)
      prefix_parameters = Array(options[:prefix_parameters])

      swagger_path("#{route_prefix}/#{route_key}") do
        operation :get do
          key :description, "Returns a list of #{model_name_plural}."
          key :tags, tags

          prefix_parameters.each do |p|
            parameter p.merge(in: :path, required: true)
          end

          response 200 do
            key :description, 'successfull operation'
            schema do
              property :data, type: :array do
                items '$ref' => data_class
              end
            end
          end
        end

        operation :post do
          key :description, "Creates a new #{model_name}."
          key :tags, tags

          prefix_parameters.each do |p|
            parameter p.merge(in: :path, required: true)
          end

          parameter name: :body,
                    in: :body,
                    description: "Attributes defining the #{model_name} to create.",
                    required: true do
            schema do
              property :data do
                key '$ref', data_class
              end
            end
          end

          response 200 do
            key :description, 'successfull operation'
            schema do
              property :data, type: :array do
                items '$ref' => data_class
              end
            end
          end

          response 422 do
            key :description, 'unprocessable entity'
            schema do
              property :errors, type: :array do
                items '$ref' => 'V1::UnprocessableEntity'
              end
            end
          end
        end
      end

      swagger_path("#{route_prefix}/#{route_key}/{id}") do
        operation :get do
          key :description, "Returns a single #{model_name}."
          key :tags, tags

          prefix_parameters.each do |p|
            parameter p.merge(in: :path, required: true)
          end

          parameter name: :id,
                    in: :path,
                    description: "ID of the #{model_name} to return.",
                    required: true,
                    type: :integer

          response 200 do
            key :description, 'successfull operation'
            schema do
              property :data, type: :array do
                items '$ref' => data_class
              end
            end
          end
        end

        operation :patch do
          key :description, "Updates an existing #{model_name}."
          key :tags, tags

          prefix_parameters.each do |p|
            parameter p.merge(in: :path, required: true)
          end

          parameter name: :id,
                    in: :path,
                    description: "ID of the #{model_name} to update.",
                    required: true,
                    type: :integer

          parameter name: :body,
                    in: :body,
                    description: "Attributes of the #{model_name} to update.",
                    required: true do
            schema do
              property :data do
                key '$ref', data_class
              end
            end
          end

          response 200 do
            key :description, 'successfull operation'
            schema do
              property :data, type: :array do
                items '$ref' => data_class
              end
            end
          end

          response 422 do
            key :description, 'unprocessable entity'
            schema do
              property :errors, type: :array do
                items '$ref' => 'V1::UnprocessableEntity'
              end
            end
          end
        end

        operation :delete do
          key :description, "Deletes an existing #{model_name}."
          key :tags, tags

          prefix_parameters.each do |p|
            parameter p.merge(in: :path, required: true)
          end

          parameter name: :id,
                    in: :path,
                    description: "ID of the #{model_name} to delete.",
                    required: true,
                    type: :integer

          response 204 do
            key :description, 'successfull operation'
          end

          response 422 do
            key :description, 'unprocessable entity'
            schema do
              property :errors, type: :array do
                items '$ref' => 'V1::UnprocessableEntity'
              end
            end
          end
        end
      end
    end

  end

end
