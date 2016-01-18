module Loggable

  private

  def inform(msg)
    log(Logger::INFO, msg)
  end

  def warn(msg)
    log(Logger::WARN, msg)
  end

  def log(level, msg)
    Rails.logger.log(level, "#{Time.zone.now.to_s(:db)} #{msg}")
  end

end
