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

  test "new users are neither admins nor blocked by default" do
    user = User.new(name: "Test User", email: "test@example.com", password: "password", time_zone: "UTC")

    assert_not user.admin?
    assert_not user.blocked?
  end

  test "authenticates the password" do
    user = User.create!(name: "Test User", email: "test@example.com", password: "password", time_zone: "UTC")

    assert user.authenticate("password")
    assert_not user.authenticate("wrong-password")
  end
end
