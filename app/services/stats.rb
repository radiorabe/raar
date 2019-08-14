class Stats

  attr_reader :date_range

  class << self
    def for(year, month = nil)
      new(Date.new(year, month || 1, 1)..Date.new(year, month || 12, -1))
    end
  end

  def initialize(date_range)
    @date_range = date_range
  end

  def tracks
    Track.within(date_range.first, date_range.last).joins(:broadcast)
  end

  def broadcasts
    Broadcast.within(date_range.first, date_range.last)
  end

  def track_durations
    @track_durations ||=
      sort_counts(tracks.group(:show_id).sum(duration_in_seconds('tracks')))
  end

  def broadcast_durations
    @broadcast_durations ||=
      sort_counts(broadcasts.group(:show_id).sum(duration_in_seconds('broadcasts')))
  end

  def broadcast_counts
    sort_counts(broadcasts.group(:show_id).count)
  end

  def overall_broadcast_duration
    broadcast_durations.values.sum
  end

  def track_ratios
    sort_counts(
      track_durations.each_with_object({}) do |(show_id, value), hash|
        hash[show_id] = value / broadcast_durations[show_id].to_f
      end
    )
  end

  def overall_track_ratio
    track_durations.values.sum / overall_broadcast_duration.to_f
  end

  def track_counts
    @track_counts ||=
      track_property_counts(tracks.group(:show_id, :artist, :title)) do |values|
        [values.first, values[1..2]]
      end
  end

  def overall_track_counts
    @overall_track_counts ||= overall_counts(track_counts)
  end

  def uniq_tracks
    sort_counts(track_counts.transform_values(&:size))
  end

  def overall_uniq_tracks
    overall_track_counts.size
  end

  def artist_combo_counts
    @artist_combo_counts ||=
      track_property_counts(tracks.group(:show_id, :artist)) do |values|
        [values.first, values.last]
      end
  end

  def overall_artist_combo_counts
    @overall_artist_combo_counts ||= overall_counts(artist_combo_counts)
  end

  def uniq_artist_combos
    sort_counts(artist_combo_counts.transform_values(&:size))
  end

  def overall_uniq_artist_combos
    overall_artist_combo_counts.size
  end

  def single_artist_counts
    artist_combo_counts.transform_values do |subhash|
      sort_counts(
        subhash.each_with_object(Hash.new(0)) do |(combo, count), hash|
          combo.split(',').map(&:strip).each do |artist|
            hash[artist] += count
          end
        end
      )
    end
  end

  def overall_single_artist_counts
    @overall_single_artist_counts ||= overall_counts(single_artist_counts)
  end

  def uniq_single_artists
    sort_counts(single_artist_counts.transform_values(&:size))
  end

  def overall_uniq_single_artists
    overall_single_artist_counts.size
  end

  # Aggregate uniq_tracks, uniq_artist_combos and uniq_single_artists
  # per hour of broadcasts duration
  def per_hour(show_counts)
    sort_counts(
      show_counts.each_with_object({}) do |(show_id, count), hash|
        hash[show_id] = count / (broadcast_durations[show_id] / 1.hour.to_f)
      end
    )
  end

  private

  def track_property_counts(scope)
    hash = Hash.new { |h, k| h[k] = {} }
    scope.count.each do |values, count|
      show_id, key = yield values
      hash[show_id][key] = count
    end
    hash.transform_values { |subhash| sort_counts(subhash) }
  end

  def overall_counts(counts)
    sort_counts(
      counts.values.each_with_object(Hash.new(0)) do |subhash, hash|
        subhash.each { |key, count| hash[key] += count }
      end
    )
  end

  def sort_counts(counts)
    Hash[counts.sort_by { |key, value| [-value, key] }]
  end

  def duration_in_seconds(table)
    case db_adapter
    when /postgres/
      "extract(epoch from (#{table}.finished_at - #{table}.started_at))"
    when /sqlite/
      "strftime('%s', #{table}.finished_at) - strftime('%s', #{table}.started_at)"
    else
      raise "Unsupported DB adapter #{db_adapter}"
    end
  end

  def db_adapter
    Track.connection.adapter_name.downcase
  end

end
