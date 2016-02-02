module V1
  class BroadcastSerializer < ApplicationSerializer

    attributes :id, :label, :started_at, :finished_at, :people, :details

    belongs_to :show, serializer: V1::ShowSerializer

  end
end
