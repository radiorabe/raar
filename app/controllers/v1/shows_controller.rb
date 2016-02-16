module V1
  class ShowsController < ListController

    self.search_columns = %w(name details)

  end
end
