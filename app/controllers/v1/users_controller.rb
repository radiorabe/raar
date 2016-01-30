module V1
  class UsersController < CrudController

    self.permitted_attrs = [:username, :first_name, :last_name, :groups]

  end
end
