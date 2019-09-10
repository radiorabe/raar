# frozen_string_literal: true

class StatusController < ApplicationController

  swagger_path '/status' do
    operation :get do
      key :description, 'Get the application status'
      key :tags, [:status, :public]

      response_entity('Status')

      response 503 do
        key :description, '(some) services unavailable'
        schema do
          property :data do
            key '$ref', 'Status'
          end
        end
      end
    end
  end

  def show
    render json: status, serializer: StatusSerializer, status: status.code
  end

  private

  def status
    @status ||= Status.new
  end

end
