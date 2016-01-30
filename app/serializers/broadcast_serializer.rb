class BroadcastSerializer < ActiveModel::Serializer

  attributes :id, :show_id, :label, :started_at, :finished_at, :people, :details

end
