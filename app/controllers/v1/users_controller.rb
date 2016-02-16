module V1
  class UsersController < CrudController

    before_action :require_admin

    self.permitted_attrs = [:username, :first_name, :last_name, :groups]

  end
end
