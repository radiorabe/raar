class Stats

  attr_reader :date_range

  class << self
    def for(year, month = nil)
      new(Date.new(year.to_i, (month || 1).to_i, 1)..Date.new(year.to_i, (month || 12).to_i, -1))
    end
  end

  def initialize(date_range)
    @date_range = date_range
  end

  def shows
    Show.where(id: broadcast_durations.keys)
  end

  def broadcast_counts
    @broadcast_counts ||= sort_counts(broadcasts.group(:show_id).count)
  end

  def overall_broadcast_count
    broadcast_counts.values.sum
  end

  def broadcast_durations
    @broadcast_durations ||= sum_hours_by_show(broadcasts, 'broadcasts')
  end

  def overall_broadcast_duration
    @overall_broadcast_duration ||= broadcast_durations.values.sum
  end

  def broadcasts?
    overall_broadcast_duration > 0
  end

  def tracks_durations
    @tracks_durations ||= sum_hours_by_show(tracks, 'tracks')
  end

  def overall_tracks_duration
    tracks_durations.values.sum
  end

  def tracks_ratios
    sort_counts(
      tracks_durations.each_with_object({}) do |(show_id, value), hash|
        hash[show_id] = value / broadcast_durations[show_id].to_f
      end
    )
  end

  def overall_tracks_ratio
    broadcasts? ? (overall_tracks_duration / overall_broadcast_duration.to_f) : nil
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
        hash[show_id] = count / broadcast_durations[show_id]
      end
    )
  end

  private

  def tracks
    Track.within(date_range.first, date_range.last).joins(:broadcast)
  end

  def broadcasts
    Broadcast.within(date_range.first, date_range.last)
  end

  def sum_hours_by_show(scope, table)
    seconds = scope.group(:show_id).sum(duration_in_seconds(table))
    hours = seconds.transform_values { |v| v / 1.hour.to_f }
    sort_counts(hours)
  end

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

  class Csv

    delegate_missing_to :@stats

    def initialize(stats)
      @stats = stats
    end

    def generate
      require 'csv'
      CSV.generate do |csv|
        csv << csv_headers
        csv << overall_columns
        shows.includes(:profile).list.each do |show|
          csv << show_columns(show)
        end
      end
    end

    private

    def csv_headers # rubocop:disable Metrics/MethodLength
      [
        'Show',
        'Profile',
        'Broadcast Count',
        'Broadcast Duration',
        'Tracks Duration',
        'Tracks Ratio',
        'Uniq Tracks Count',
        'Unique Artist Combo Count',
        'Unique Single Artist Count',
        'Unique Tracks per hour',
        'Unique Artist Combos per hour',
        'Unique Single Artists per hour'
      ]
    end

    def overall_columns # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      [
        'Overall',
        nil,
        overall_broadcast_count,
        overall_broadcast_duration,
        overall_tracks_duration,
        overall_tracks_ratio,
        overall_uniq_tracks,
        overall_uniq_artist_combos,
        overall_uniq_single_artists,
        broadcasts? ? overall_uniq_tracks / overall_broadcast_duration : nil,
        broadcasts? ? overall_uniq_artist_combos / overall_broadcast_duration : nil,
        broadcasts? ? overall_uniq_single_artists / overall_broadcast_duration : nil
      ]
    end

    def show_columns(show) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      [
        show.name,
        show.profile.name,
        broadcast_counts[show.id],
        broadcast_durations[show.id],
        tracks_durations[show.id],
        tracks_ratios[show.id],
        uniq_tracks[show.id],
        uniq_artist_combos[show.id],
        uniq_single_artists[show.id],
        per_hour(uniq_tracks)[show.id],
        per_hour(uniq_artist_combos)[show.id],
        per_hour(uniq_single_artists)[show.id]
      ]
    end

  end

end
