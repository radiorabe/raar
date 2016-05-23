# Sort functionality for the index table.
# Define a default sort expression that is always appended to the
# current sort params with the class attribute +default_sort+.
# Prefix a sort field with `-` to get a descending order.
module Sortable

  def self.prepended(klass)
    klass.class_attribute :sort_mappings_with_indifferent_access
    klass.sort_mappings_with_indifferent_access = {}.with_indifferent_access

    klass.class_attribute :default_sort

    klass.before_action :handle_invalid_sort

    klass.extend ClassMethods
  end

  private

  # Enhance the list entries with an optional sort order.
  def fetch_entries
    sortable = sortable?
    if sortable || default_sort
      clause = [sortable ? sort_expression : nil, default_sort]
      super.reorder(clause.compact.join(', '))
    else
      super
    end
  end

  # Return the sort expression to be used in the list query.
  def sort_expression
    sort, order = sort_with_order
    col = sort_mappings_with_indifferent_access[sort] ||
          "#{model_class.table_name}.#{sort}"
    "#{col} #{order}"
  end

  # Split the sort param into sort field and order.
  def sort_with_order
    sort = params[:sort].gsub(/\A\-/, '')
    [sort, sort == params[:sort] ? 'ASC' : 'DESC']
  end

  # Returns true if the passed attribute is sortable.
  def sortable?
    return false if params[:sort].blank?
    attr = sort_with_order.first
    attr.present? && (
    model_class.column_names.include?(attr.to_s) ||
    sort_mappings_with_indifferent_access.include?(attr))
  end

  # Conform to json api and notify client about invalid sort param
  def handle_invalid_sort
    head 400 if params[:sort].present? && !sortable?
  end

  # Class methods for sorting.
  module ClassMethods

    # Define a map of (virtual) attributes to SQL order expressions.
    # May be used for sorting table columns that do not appear directly
    # in the database table. E.g., map city_id: 'cities.name' to
    # sort the displayed city names.
    def sort_mappings=(hash)
      self.sort_mappings_with_indifferent_access =
        hash.with_indifferent_access
    end

  end

end
