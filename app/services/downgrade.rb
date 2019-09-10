# frozen_string_literal: true

module Downgrade

  def self.run
    Downgrader.run
    Ereaser.run
  rescue Exception => e # rubocop:disable Lint/RescueException
    # make sure we get notified in absolutely all cases.
    Rails.logger.error("FATAL #{e}\n  #{e.backtrace.join("\n  ")}")
    ExceptionNotifier.notify_exception(e)
  end

end
