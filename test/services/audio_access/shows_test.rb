# frozen_string_literal: true

require 'test_helper'

class AudioAccess::ShowsTest < ActiveSupport::TestCase

  test '#filter for user nil contains only shows' do
    assert_equal shows(:g9s, :info), accessibles(nil)
  end

  test '#filter for user User.new contains only shows' do
    assert_equal shows(:g9s, :info, :klangbecken), accessibles(User.new)
  end

  test '#filter for user member contains only shows' do
    assert_equal shows(:g9s, :info, :klangbecken), accessibles(users(:member))
  end

  test '#filter for user admin contains all shows' do
    assert_equal shows(:g9s, :info, :klangbecken), accessibles(users(:admin))
  end

  test '#filter for user member contains no shows without archive format' do
    archive_formats(:default_mp3).destroy
    assert_equal shows(:info, :klangbecken), accessibles(users(:member))
  end

  test '#filter for user admin contains all shows without archive format' do
    archive_formats(:default_mp3).destroy
    assert_equal shows(:g9s, :info, :klangbecken), accessibles(users(:admin))
  end

  private

  def accessibles(user)
    AudioAccess::Shows.new(user).filter(Show.list)
  end

end
