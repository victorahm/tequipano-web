require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    user = User.new(name: "Test User", email: "test@example.com", password: "password", time_zone: "UTC")
    assert user.valid?
  end

  test "should require name" do
    user = User.new(email: "test@example.com", password: "password", time_zone: "UTC")
    assert_not user.valid?
  end

  test "should require email" do
    user = User.new(name: "Test User", password: "password", time_zone: "UTC")
    assert_not user.valid?
  end

  test "should require unique email" do
    User.create!(name: "User1", email: "test@example.com", password: "password", time_zone: "UTC")
    user = User.new(name: "User2", email: "test@example.com", password: "password", time_zone: "UTC")
    assert_not user.valid?
  end
end
