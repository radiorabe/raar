module Admin
  class AudioEncodingsController < ApplicationController

    include Admin::Authenticatable

    swagger_path '/admin/audio_encodings' do
      operation :get do
        key :description, 'Returns a list of available audio encodings.'
        key :tags, [:audio_encoding, :admin]

        response_entities('Admin::AudioEncoding')

        security http_token: []
        security api_token: []
      end
    end

    def index
      render json: AudioEncoding.list.sort_by(&:codec),
             each_serializer: Admin::AudioEncodingSerializer
    end

  end
end
