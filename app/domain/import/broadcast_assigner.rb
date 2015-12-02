module Import
  # Assigns broadcasts to a list of recording files.
  class BroadcastAssigner

    attr_reader :files

    def initialize(files_by_time)
      @files = files
    end

    def assign
      metadata.find_broadcast_datas(files)
      finished_broadcasts_with_files
    end

  end
end
