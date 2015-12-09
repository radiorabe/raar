module Airtime

  # https://github.com/sourcefabric/airtime/blob/2.5.x/airtime_mvc/build/schema.xml
  class Base < ActiveRecord::Base

    self.abstract_class = true
    self.table_name_prefix = 'cc_'

    establish_connection(:airtime)

  end
end
