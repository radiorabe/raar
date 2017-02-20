module Convert

  # rubocop:disable Lint/RescueException
  # make sure we get notified in absolutely all cases.

  def self.run(directory)
    Converter.new(directory).run
  rescue Exception => e
    Rails.logger.error("FATAL #{e}\n  #{e.backtrace.join("\n  ")}")
    ExceptionNotifier.notify_exception(e)
  end

end
