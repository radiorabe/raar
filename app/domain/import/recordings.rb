require 'time'

module Import
  # Handles the recording files in the import directories.
  class Recordings

    DATE_GLOB = '[12][019][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'
    TIME_GLOB = '[0-2][0-9][0-5][0-9][0-5][0-9]{+,-}[0-2][0-9][0-5]0'
    DATE_TIME_GLOB = "#{DATE_GLOB}T#{TIME_GLOB}"
    DATE_TIME_FORMAT = '%Y-%m-%dT%H%M%S%z'

    def by_time
      result = Hash.new { |h, k| h[k] = [] }
      import_directories.each_with_object(result) do |d, h|
        Dir.glob(File.join(d, DATE_TIME_GLOB + '.*')).each do |f|
          h[parse_datetime(f)] << f
        end
      end
    end

    def mark_imported(files)
      files.each do |f|
        FileUtils.mv(f, f.gsub(/(\..+)\z/, '_imported\1'))
      end
    end

    def clear_old_imported
      import_directories.each do |d|
        Dir.glob(File.join(d, DATE_TIME_GLOB + '_imported.*')).each do |f|
          if parse_datetime(f).to_date < Date.today - days_to_keep_imported
            FileUtils.rm(f)
          end
        end
      end
    end

    def import_directories
      Rails.application.secrets.import_directories
    end

    def days_to_keep_imported
      Rails.application.secrets.days_to_keep_imported
    end

    private

    def parse_datetime(path)
      name = File.basename(path, '.*')
      Time.strptime(name, DATE_TIME_FORMAT)
    end

  end
end
