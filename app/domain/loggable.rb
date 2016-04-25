module Loggable

  private

  def inform(msg)
    log('INFO', msg)
  end

  def warn(msg)
    log('WARN', msg)
  end

  def error(msg)
    log('ERROR', msg)
  end

  def log(level, msg)
    Rails.logger.log(Logger.const_get(level), "#{level} #{Time.zone.now} #{msg}")
  end

end
