# frozen_string_literal: true

module TimeFilterable

  TIME_PARTS = [:year, :month, :day, :hour, :min, :sec].freeze

  private

  def start_finish
    parts = param_time_parts
    start = get_timestamp(parts)
    finish = start + range(parts)
    [start, finish]
  end

  def param_time_parts
    parts = params.values_at(*TIME_PARTS).compact
    time = params[:time].to_s.match(/^(\d{2})(\d{2})?(\d{2})?$/)
    parts += time[1..3].compact if time && parts.size == 3
    parts
  end

  def range(parts)
    range = TIME_PARTS[parts.size - 1]
    case range
    when :min then 1.minute
    when :sec then 1.second
    else 1.send(range)
    end
  end

  def get_timestamp(parts)
    Time.zone.local(*parts)
  rescue ArgumentError
    not_found
  end

end
