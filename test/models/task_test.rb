require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @list = lists(:one)
    @task = tasks(:one)
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

  test "allowed_next_statuses returns every status for a new task" do
    assert_equal Task.statuses.keys.sort, Task.new.allowed_next_statuses.sort
  end

  test "allowed_next_statuses keeps the current status and its transitions" do
    @task.update_columns(status: "doing")

    assert_equal %w[ done doing paused blocked ].sort, @task.allowed_next_statuses.sort
  end

  test "allows the documented status transitions" do
    [
      %w[ todo doing ],
      %w[ doing done ],
      %w[ doing paused ],
      %w[ doing blocked ],
      %w[ paused doing ],
      %w[ blocked doing ],
      %w[ done todo ]
    ].each do |from, to|
      @task.update_columns(status: from, completed_at: nil)
      @task.status = to

      assert @task.valid?, "expected #{from} → #{to} to be a valid transition"
      assert @task.save, "expected #{from} → #{to} to save"
    end
  end

  test "rejects status transitions outside the state machine" do
    [
      %w[ todo done ],
      %w[ todo paused ],
      %w[ todo blocked ],
      %w[ done doing ],
      %w[ paused done ],
      %w[ blocked todo ]
    ].each do |from, to|
      @task.update_columns(status: from, completed_at: nil)
      @task.status = to

      assert_not @task.valid?, "expected #{from} → #{to} to be invalid"
      assert_includes @task.errors[:status], "can't change from #{from} to #{to}"
    end
  end

  test "allows a new task to start in any status" do
    task = @list.tasks.build(title: "Imported", user: @user, position: 9, status: "done")

    assert task.save
    assert_equal "done", task.status
  end

  test "sets completed_at when the task becomes done" do
    @task.update_columns(status: "doing", completed_at: nil)

    @task.update!(status: "done")

    assert_not_nil @task.completed_at
    assert_in_delta Time.current, @task.completed_at, 2.seconds
  end

  test "clears completed_at when a done task is reopened" do
    @task.update_columns(status: "done", completed_at: 1.day.ago)

    @task.update!(status: "todo")

    assert_nil @task.completed_at
  end
end
