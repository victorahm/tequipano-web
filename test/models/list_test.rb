require "test_helper"

class ListTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "should be valid with valid attributes" do
    list = List.new(user: @user, name: "My List", color: "#FF0000", position: 1)
    assert list.valid?
  end

  test "should require name" do
    list = List.new(user: @user, color: "#FF0000", position: 1)
    assert_not list.valid?
  end
end
