require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @list = lists(:one)
  end

  test "should be valid with valid attributes" do
    task = Task.new(user: @user, list: @list, title: "Test Task", status: "todo", position: 1)
    assert task.valid?
  end

  test "should require title" do
    task = Task.new(user: @user, list: @list, status: "todo", position: 1)
    assert_not task.valid?
  end

  test "should require status" do
    task = Task.new(user: @user, list: @list, title: "Test Task", position: 1)
    assert_not task.valid?
  end
end
