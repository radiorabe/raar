# A generic controller to display, create, update and destroy entries of a certain model class.
class CrudController < ListController

  class_attribute :permitted_attrs

  # POST /users
  def create
    if entry.save
      render json: entry, status: :created, location: entry_url
    else
      render json: entry.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if entry.update(model_params)
      render json: entry
    else
      render json: entry.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    entry.destroy
  end

  private

  def fetch_entry
    params[:id] ? super : model_class.new(model_params)
  end

  def entry_url
    prefix = self.class.name.deconstantize.underscore.gsub('/', '_')
    send("#{prefix}_#{entry.class.model_name.singular_route_key}_url", entry)
  end

  # Only allow a trusted parameter "white list" through.
  def model_params
    params.require(model_identifier).permit(permitted_attrs)
  end

end
