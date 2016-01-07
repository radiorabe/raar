module RecordingHelper
  extend ActiveSupport::Concern

  included do
    setup :create_import_dir
    teardown :clear_import_dir
  end

  private

  def file(name)
    File.join(import_directory, name)
  end

  def touch(name)
    file(name).tap { |f| FileUtils.touch(f) }
  end

  def import_directory
    Import::Recording::Finder.new.import_directories.first
  end

  def create_import_dir
    FileUtils.mkdir_p(import_directory)
  end

  def clear_import_dir
    FileUtils.rm_rf(import_directory)
  end

end
