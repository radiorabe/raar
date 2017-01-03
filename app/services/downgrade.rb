module Downgrade

  # rubocop:disable Lint/RescueException
  # make sure we get notified in absolutely all cases.

  def self.run
    Downgrader.run
    Ereaser.run
  rescue Exception => e
    Rails.logger.error("FATAL #{e}\n  #{e.backtrace.join("\n  ")}")
    ExceptionNotifier.notify_exception(e)
  end

end
