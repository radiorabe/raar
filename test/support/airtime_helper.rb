module AirtimeHelper
  extend ActiveSupport::Concern

  included do
    setup :setup_airtime
    parallelize_setup { |worker| create_airtime_db(worker) }
  end

  module ClassMethods
    def create_airtime_db(worker)
      Airtime::Base.establish_connection(
        adapter: :sqlite3,
        database: "db/airtime_test_#{worker}.sqlite3"
      )
    end
  end

  private

  def setup_airtime
    if Airtime::Base.connection.data_sources.present?
      clear_airtime_db
    else
      create_show_table
      create_show_instances_table
    end
  end

  def create_show_table
    Airtime::Base.connection.create_table :cc_show do |t|
      t.string :name, null: false
      t.string :url
      t.string :genre
      t.string :description, limit: 512
      t.string :color, limit: 6
      t.string :background_color, limit: 6
      t.boolean :live_stream_using_airtime_auth, default: false
      t.boolean :live_stream_using_custom_auth, default: false
      t.string :live_stream_user
      t.string :live_stream_pass
      t.boolean :linked, null: false, default: false
      t.boolean :is_linkable, null: false, default: true
    end
  end

  def create_show_instances_table
    Airtime::Base.connection.create_table :cc_show_instances do |t|
      t.timestamp :starts, null: false
      t.timestamp :ends, null: false
      t.integer :show_id, null: false
      t.integer :record, default: 0, limit: 2
      t.integer :rebroadcast, default: 0, limit: 2
      t.integer :instance_id
      t.integer :file_id
      t.column :time_filled, :interval
      t.timestamp :created, null: false
      t.timestamp :last_scheduled
      t.boolean :modified_instance, null: false, default: false
    end
  end

  def clear_airtime_db
    Airtime::ShowInstance.delete_all
    Airtime::Show.delete_all
  end

end
