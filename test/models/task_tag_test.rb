require "test_helper"

class TaskTagTest < ActiveSupport::TestCase
  def setup
    @task = tasks(:one)
    @tag = tags(:one)
  end

  test "should be valid with valid attributes" do
    task_tag = TaskTag.new(task: @task, tag: @tag)
    assert task_tag.valid?
  end
end
