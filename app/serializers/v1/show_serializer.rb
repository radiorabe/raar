module V1
  class ShowSerializer < ApplicationSerializer

    attributes :id, :name, :details

    belongs_to :profile

  end
end
