module TimeFilterable

  extend ActiveSupport::Concern

  TIME_PARTS = [:year, :month, :day, :hour, :min, :sec].freeze

  included do
    before_action :assert_params_given, only: :index
  end

  private

  def start_finish
    parts = params.values_at(*TIME_PARTS).compact
    start = get_timestamp(parts)
    finish = start + range(parts)
    [start, finish]
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

  def assert_params_given
    not_found unless index_params?
  end

  def index_params?
    params[:show_id].present? || params[:year].present? || params[:q].present?
  end

end
