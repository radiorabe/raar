# A generic controller to display entries of a certain model class.
class ListController < ApplicationController

  prepend Searchable

  delegate :model_class, :model_identifier, :model_serializer,
           to: 'self.class'

  # GET /users
  def index
    render json: fetch_entries, each_serializer: model_serializer
  end

  # GET /users/1
  def show
    render json: entry, serializer: model_serializer
  end

  private

  def entry
    instance_variable_get(:"@#{ivar_name}") ||
      instance_variable_set(:"@#{ivar_name}", fetch_entry)
  end

  def fetch_entries
    model_scope.list
  end

  def fetch_entry
    model_scope.find(params.fetch(:id))
  end

  def ivar_name
    model_class.model_name.param_key
  end

  def model_scope
    model_class
  end

  class << self

    # The ActiveRecord class of the model.
    def model_class
      @model_class ||= controller_name.classify.constantize
    end

    # The identifier of the model used for form parameters.
    # I.e., the symbol of the underscored model name.
    def model_identifier
      @model_identifier ||= model_class.model_name.param_key
    end

    def model_serializer
      @model_serializer ||= "#{name.deconstantize}::#{model_class.name}Serializer".constantize
    end

  end

end
