require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "should be valid with valid attributes" do
    token = ApiToken.new(user: @user, token: "abc123", expires_at: 1.day.from_now)
    assert token.valid?
  end

  test "should require token" do
    token = ApiToken.new(user: @user, expires_at: 1.day.from_now)
    assert_not token.valid?
  end

  test "should require expires_at" do
    token = ApiToken.new(user: @user, token: "abc123")
    assert_not token.valid?
  end
end
