# frozen_string_literal: true

module Stats
  class Shows < Base

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
      overall_broadcast_duration.positive?
    end

    def tracks_durations
      @tracks_durations ||= sum_hours_by_show(tracks, 'tracks')
    end

    def overall_tracks_duration
      tracks_durations.values.sum
    end

    def tracks_ratios
      @tracks_ratios ||=
        sort_counts(
          tracks_durations.each_with_object({}) do |(show_id, value), hash|
            hash[show_id] = value / broadcast_durations[show_id].to_f
          end
        )
    end

    def overall_tracks_ratio
      broadcasts? ? (overall_tracks_duration / overall_broadcast_duration.to_f) : nil
    end

    def uniq_tracks
      @uniq_tracks ||=
        sort_counts(tracks.group(:show_id).distinct.count(:title))
    end

    def overall_uniq_tracks
      tracks.distinct.count(:title)
    end

    def uniq_artist_combos
      @uniq_artist_combos ||=
        sort_counts(tracks.group(:show_id).distinct.count(:artist))
    end

    def overall_uniq_artist_combos
      tracks.distinct.count(:artist)
    end

    def to_csv
      Csv.new(self).generate
    end

    private

    def broadcasts
      Broadcast.within(date_range.first, date_range.last)
    end

    def sum_hours_by_show(scope, table)
      seconds = scope.group(:show_id).sum(duration_in_seconds(table))
      hours = seconds.transform_values { |v| v / 1.hour.to_f }
      sort_counts(hours)
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

      def csv_headers
        [
          'Show',
          'Profile',
          'Broadcast Count',
          'Broadcast Duration',
          'Tracks Duration',
          'Tracks Ratio',
          'Uniq Tracks Count',
          'Unique Artist Combo Count'
        ]
      end

      def overall_columns
        [
          'Overall',
          nil,
          overall_broadcast_count,
          overall_broadcast_duration,
          overall_tracks_duration,
          overall_tracks_ratio,
          overall_uniq_tracks,
          overall_uniq_artist_combos
        ]
      end

      def show_columns(show) # rubocop:disable Metrics/AbcSize
        [
          show.name,
          show.profile.name,
          broadcast_counts[show.id],
          broadcast_durations[show.id],
          tracks_durations[show.id],
          tracks_ratios[show.id],
          uniq_tracks[show.id],
          uniq_artist_combos[show.id]
        ]
      end

    end

  end

end
