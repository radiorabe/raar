module Downgrade

  # rubocop:disable Lint/RescueException
  # make sure we get notified in absolutely all cases.

  def self.run
    Downgrader.run
    Ereaser.run
  rescue Exception => e
    ExceptionNotifier.notify_exception(e)
  end

end
