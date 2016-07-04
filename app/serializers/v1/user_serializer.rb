module V1
  class UserSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property 'username', type: :string
        property 'first-name', type: :string
        property 'last-name', type: :string
        property 'groups', type: :array, items: { type: :string }
        property 'api-key', type: :string, readOnly: true
        property 'api-key-expires-at', type: :string, format: 'date-time', readOnly: true
        property 'admin', type: :boolean, readOnly: true
        property 'created-at', type: :string, format: 'date-time', readOnly: true
        property 'updated-at', type: :string, format: 'date-time', readOnly: true
      end
    end

    attributes :id, :username, :first_name, :last_name, :groups,
               :api_key, :api_key_expires_at, :created_at, :updated_at

    attribute :admin?, key: :admin

    def groups
      object.group_list
    end

  end
end
