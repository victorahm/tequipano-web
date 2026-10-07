require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def setup
    @task = tasks(:one)
    @user = users(:one)
  end

  test "should be valid with valid attributes" do
    comment = Comment.new(task: @task, user: @user, body: "This is a comment")
    assert comment.valid?
  end

  test "should require body" do
    comment = Comment.new(task: @task, user: @user)
    assert_not comment.valid?
  end
end
