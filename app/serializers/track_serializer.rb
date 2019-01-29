# == Schema Information
#
# Table name: tracks
#
#  id           :integer          not null, primary key
#  title        :string           not null
#  artist       :string
#  started_at   :datetime         not null
#  finished_at  :datetime         not null
#  broadcast_id :integer
#

class TrackSerializer < ApplicationSerializer

  json_api_swagger_schema do
    property :attributes do
      property :title, type: :string
      property :artist, type: :string
      property :started_at, type: :string, format: 'date-time'
      property :finished_at, type: :string, format: 'date-time'
    end
    property :links do
      property :self, type: :string, format: 'url', readOnly: true
    end
  end

  attributes :id, :title, :artist, :started_at, :finished_at

  link(:self) { track_path(object) }

end
