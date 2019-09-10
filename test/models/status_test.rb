require 'test_helper'

class StatusTest < ActiveSupport::TestCase

  setup do
    @original_home = Rails.application.secrets.archive_home
  end

  teardown do
    Rails.application.secrets.archive_home = @original_home
  end

  test 'database is true if shows exist' do
    assert_equal true, Status.new.database
  end

  test 'database is false if no shows exist' do
    Show.delete_all
    assert_equal false, Status.new.database
  end

  test 'database is false if query fails' do
    Show.expects(:count).raises
    assert_equal false, Status.new.database
  end

  test 'file_system is true if directory has content' do
    FileUtils.mkdir_p(FileStore::Structure.home)
    FileUtils.touch(File.join(FileStore::Structure.home, 'dummy_content.data'))
    assert_equal true, Status.new.file_system
  end

  test 'file_system is false if directory does not exist' do
    Rails.application.secrets.archive_home = '/does/not/exist'
    assert_equal false, Status.new.file_system
  end

end