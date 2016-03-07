module V1
  class AudioEncodingsController < ApplicationController

    before_action :require_admin

    swagger_path '/v1/audio_encodings' do
      operation :get do
        key :description, 'Returns a list of available audio encodings.'
        key :tags, [:audio_encoding, :admin]

        response 200 do
          key :description, 'successfull operation'
          schema do
            property :data, type: :array do
              items '$ref' => 'V1::AudioEncoding'
            end
          end
        end
      end
    end

    def index
      render json: AudioEncoding.list.sort_by(&:codec),
             each_serializer: V1::AudioEncodingSerializer
    end

  end
end
