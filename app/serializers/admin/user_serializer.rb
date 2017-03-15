module Admin
  class UserSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property :username, type: :string
        property :first_name, type: :string
        property :last_name, type: :string
        property :groups, type: :array, items: { type: :string }
        property :admin, type: :boolean, readOnly: true
        property :created_at, type: :string, format: 'date-time', readOnly: true
        property :updated_at, type: :string, format: 'date-time', readOnly: true
      end
      property :links do
        property :self, type: :string, format: 'url', readOnly: true
      end
    end

    attributes :id, :username, :first_name, :last_name, :groups,
               :created_at, :updated_at

    attribute :admin?, key: :admin

    link(:self) { admin_user_path(object) }

    def groups
      object.group_list
    end

  end
end
