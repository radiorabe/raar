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
    Rails.logger.add(Logger.const_get(level), "#{level} #{msg}")
  end

end
