# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:alice)
  end

  test 'name_or_email' do
    assert_equal 'alice', @user.name_or_email

    @user.name = ''
    assert_equal 'alice@example.com', @user.name_or_email
  end
end
