# A generic controller to display entries of a certain model class.
class ListController < ApplicationController

  delegate :model_class, :model_identifier, to: 'self.class'

  # GET /users
  def index
    render json: fetch_entries
  end

  # GET /users/1
  def show
    render json: entry
  end

  private

  def entry
    instance_variable_get(:"@#{ivar_name}") ||
      instance_variable_set(:"@#{ivar_name}", fetch_entry)
  end

  def fetch_entries
    model_class.list
  end

  def fetch_entry
    model_class.find(params[:id])
  end

  def ivar_name
    model_class.model_name.param_key
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

  end

end
