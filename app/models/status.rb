# frozen_string_literal: true

class Status < ActiveModelSerializers::Model

  def api
    true
  end

  def database
    return @database if defined?(@database)

    @database =
      begin
        Show.count.positive?
      rescue StandardError
        false
      end
  end

  def file_system
    return @file_system if defined?(@file_system)

    @file_system =
      begin
        Dir.glob(File.join(FileStore::Structure.home, '*')).present?
      rescue StandardError
        false
      end
  end

  def code
    database && file_system ? :ok : :service_unavailable
  end

end
