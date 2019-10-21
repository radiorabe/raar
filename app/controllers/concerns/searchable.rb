# frozen_string_literal: true

# The search functionality for the index table.
# Define an array of searchable string columns in your subclassing
# controllers using the class attribute +search_columns+.
module Searchable

  def self.prepended(klass)
    klass.class_attribute :search_columns
    klass.search_columns = []
  end

  private

  # Enhance the list entries with an optional search criteria
  def fetch_entries
    super.where(search_conditions)
  end

  # Concat the word clauses with AND.
  def search_conditions
    return unless search_support? && params[:q].present?

    search_word_conditions
  end

  # Split the search query in single words and create a list of word clauses.
  def search_word_conditions
    params[:q]
      .split(/\s+/)
      .map { |w| search_word_condition(w) }
      .reduce { |query, condition| query.and(condition) }
  end

  # Create a search query for a single word.
  def search_word_condition(word)
    search_table_columns_condition(word, model_class.arel_table, *search_columns)
  end

  # Create a list of Arel #matches queries for each column and the given
  # word and concat the conditions wit OR.
  def search_table_columns_condition(word, table, *fields)
    fields
      .map { |field| arel_match(table, field, word) }
      .reduce { |query, cond| query.or(cond) }
  end

  def arel_match(table, field, word)
    table[field].matches(Arel::Nodes::Quoted.new("%#{word}%"))
  end

  # Returns true if this controller has searchable columns.
  def search_support?
    search_columns.present?
  end

end
