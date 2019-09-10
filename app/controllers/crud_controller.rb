# frozen_string_literal: true

# A generic controller to display, create, update and destroy entries of a certain model class.
class CrudController < ListController

  class_attribute :permitted_attrs

  # POST /users
  def create
    build_entry
    if entry.save
      render json: entry, status: :created, location: entry_url, serializer: model_serializer
    else
      render json: entry,
             status: :unprocessable_entity,
             serializer: ActiveModel::Serializer::ErrorSerializer
    end
  end

  # PATCH/PUT /users/1
  def update
    if entry.update(model_params)
      render json: entry, serializer: model_serializer
    else
      render json: entry,
             status: :unprocessable_entity,
             serializer: ActiveModel::Serializer::ErrorSerializer
    end
  end

  # DELETE /users/1
  def destroy
    if entry.destroy
      head 204
    else
      render json: entry,
             status: :unprocessable_entity,
             serializer: ActiveModel::Serializer::ErrorSerializer
    end
  end

  private

  def entry_url
    prefix = self.class.name.deconstantize.underscore.tr('/', '_')
    send("#{prefix}_#{entry.class.model_name.singular_route_key}_path", entry)
  end

  def build_entry
    instance_variable_set(:"@#{ivar_name}", model_scope.new(model_params))
  end

  # Only allow a trusted parameter "white list" through.
  def model_params
    params.require('data').require('attributes').permit(permitted_attrs)
  end

end
