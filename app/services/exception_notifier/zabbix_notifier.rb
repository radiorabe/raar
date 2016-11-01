module ExceptionNotifier
  # try http://spin.atomicobject.com/2012/10/30/collecting-metrics-from-ruby-processes-using-zabbix-trappers/
  class ZabbixNotifier

    def initialize(_options = {})
      # do something with the options...
    end

    def call(_exception, _options = {})
      # send the notification
    end

  end
end
