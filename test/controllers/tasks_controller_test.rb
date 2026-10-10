require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  TURBO_STREAM_HEADERS = { "ACCEPT" => "text/vnd.turbo-stream.html, text/html, application/xhtml+xml" }.freeze

  setup do
    @current_user = User.order(:id).first
    @list = List.find_by!(user: @current_user)
    @task = Task.find_by!(user: @current_user)
    @task.update_columns(status: "todo", completed_at: nil)
    @other_list = List.where.not(user: @current_user).first
    @other_task = Task.find_by!(user: @other_list.user)
  end

  test "index renders all tasks of every list of the current user" do
    work = @current_user.lists.create!(name: "Work", color: "#ff0000", position: 2)
    work.tasks.create!(title: "Alice other list task", user: @current_user, status: "todo", position: 1)

    get tasks_url

    assert_response :success
    assert_select "h1.app-main__title", "Tasks"
    assert_select "ul#tasks li.task-card", 2
    assert_select "ul#tasks li.task-card", text: /#{Regexp.escape(@task.title)}/
    assert_select "ul#tasks li.task-card", text: /Alice other list task/
    assert_not_includes response.body, @other_task.title
  end

  test "index shows the list each task belongs to" do
    get tasks_url

    assert_response :success
    assert_select "ul#tasks a[href=?]", list_path(@list)
  end

  test "index renders an empty state when the user has no tasks" do
    Task.where(user: @current_user).destroy_all

    get tasks_url

    assert_response :success
    assert_select "ul#tasks .task-list__empty"
    assert_select "ul#tasks li.task-card", 0
  end

  test "index as json renders only the current user's tasks" do
    get tasks_url(format: :json)

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal [ @task.id ], payload.map { |task| task["id"] }
  end

  test "side menu links to the tasks index" do
    get tasks_url

    assert_response :success
    assert_select "aside a.side-menu__link.is-active[href=?]", tasks_path
  end

  test "show renders the current user's task" do
    get list_task_url(@list, @task)

    assert_response :success
    assert_select "h1.app-main__title", @task.title
    assert_select "a[href=?]", list_path(@list)
  end

  test "show as json renders the task" do
    get list_task_url(@list, @task, format: :json)

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal @task.id, payload["id"]
    assert_equal @task.title, payload["title"]
    assert_equal @list.id, payload["list_id"]
  end

  test "show of another user's task returns not found" do
    get list_task_url(@other_list, @other_task)

    assert_response :not_found
  end

  test "show of a task outside the given list returns not found" do
    get list_task_url(@other_list, @task)

    assert_response :not_found
  end

  test "new renders the task form nested in the list" do
    get new_list_task_url(@list)

    assert_response :success
    assert_select "form[action=?]", list_tasks_path(@list)
    assert_select "input[name=?]", "task[title]"
    assert_select "select[name=?]", "task[status]"
  end

  test "create saves a task in the list owned by the current user" do
    assert_difference "Task.count", 1 do
      post list_tasks_url(@list), params: { task: { title: "Buy milk", description: "Semi-skimmed", status: "todo", position: 7 } }
    end

    created = Task.order(:id).last
    assert_redirected_to list_url(@list)
    assert_equal @list, created.list
    assert_equal @current_user, created.user
    assert_equal "Buy milk", created.title
    assert_equal "Semi-skimmed", created.description
    assert_equal 7, created.position
  end

  test "create defaults the status to todo and to the next position" do
    expected_position = @list.tasks.maximum(:position).to_i + 1

    post list_tasks_url(@list), params: { task: { title: "Quick add" } }

    created = Task.order(:id).last
    assert_redirected_to list_url(@list)
    assert_equal "todo", created.status
    assert_equal expected_position, created.position
  end

  test "create ignores a forged user_id" do
    post list_tasks_url(@list), params: { task: { title: "Forged", user_id: @other_task.user_id } }

    assert_equal @current_user, Task.order(:id).last.user
  end

  test "create in another user's list returns not found" do
    assert_no_difference "Task.count" do
      post list_tasks_url(@other_list), params: { task: { title: "Intruder" } }
    end

    assert_response :not_found
  end

  test "create with invalid data renders the form with errors" do
    assert_no_difference "Task.count" do
      post list_tasks_url(@list), params: { task: { title: "" } }
    end

    assert_response :unprocessable_content
    assert_select ".form__group--error .form__error", minimum: 1
  end

  test "create as json responds with created" do
    post list_tasks_url(@list, format: :json), params: { task: { title: "API task", status: "todo", position: 3 } }

    assert_response :created
    payload = JSON.parse(response.body)
    assert_equal "API task", payload["title"]
    assert_equal @list.id, payload["list_id"]
    assert_equal @current_user.id, payload["user_id"]
  end

  test "create as json with invalid data responds with unprocessable" do
    post list_tasks_url(@list, format: :json), params: { task: { title: "" } }

    assert_response :unprocessable_content
    assert JSON.parse(response.body).key?("title")
  end

  test "create as turbo stream redirects to the list" do
    post list_tasks_url(@list), params: { task: { title: "Stream task" } },
      headers: TURBO_STREAM_HEADERS

    assert_response :see_other
    assert_redirected_to list_url(@list)
  end

  test "create as turbo stream with invalid data renders the form with errors" do
    post list_tasks_url(@list), params: { task: { title: "" } },
      headers: TURBO_STREAM_HEADERS

    assert_response :unprocessable_content
    assert_select ".form__group--error .form__error", minimum: 1
  end

  test "edit renders the task form" do
    get edit_list_task_url(@list, @task)

    assert_response :success
    assert_select "form[action=?]", list_task_path(@list, @task)
    assert_select "input[name=?][value=?]", "task[title]", @task.title
  end

  test "edit only offers the allowed status transitions" do
    get edit_list_task_url(@list, @task)

    assert_response :success
    assert_select "select[name='task[status]'] option", 2
    assert_select "select[name='task[status]'] option[value=todo]"
    assert_select "select[name='task[status]'] option[value=doing]"
    assert_select "select[name='task[status]'] option[value=done]", 0
  end

  test "edit of another user's task returns not found" do
    get edit_list_task_url(@other_list, @other_task)

    assert_response :not_found
  end

  test "update changes the task attributes" do
    patch list_task_url(@list, @task), params: { task: { title: "Renamed", description: "New body", status: "doing", position: 5 } }

    assert_redirected_to list_url(@list)
    @task.reload
    assert_equal "Renamed", @task.title
    assert_equal "New body", @task.description
    assert_equal "doing", @task.status
    assert_equal 5, @task.position
    assert_equal @list, @task.list
  end

  test "update allows a valid status transition" do
    patch list_task_url(@list, @task), params: { task: { status: "doing" } }

    assert_redirected_to list_url(@list)
    assert_equal "doing", @task.reload.status
  end

  test "update rejects an invalid status transition" do
    patch list_task_url(@list, @task), params: { task: { status: "done" } }

    assert_response :unprocessable_content
    assert_equal "todo", @task.reload.status
  end

  test "update with invalid data renders the form with errors" do
    patch list_task_url(@list, @task), params: { task: { title: "" } }

    assert_response :unprocessable_content
    assert_select ".form__group--error .form__error", minimum: 1
  end

  test "update as json responds with ok" do
    patch list_task_url(@list, @task, format: :json), params: { task: { title: "Renamed via JSON" } }

    assert_response :success
    assert_equal "Renamed via JSON", JSON.parse(response.body)["title"]
  end

  test "update as turbo stream redirects to the list" do
    patch list_task_url(@list, @task), params: { task: { title: "Stream renamed" } },
      headers: TURBO_STREAM_HEADERS

    assert_response :see_other
    assert_redirected_to list_url(@list)
    assert_equal "Stream renamed", @task.reload.title
  end

  test "update of another user's task returns not found" do
    patch list_task_url(@other_list, @other_task), params: { task: { title: "Hijacked" } }

    assert_response :not_found
    assert_not_equal "Hijacked", @other_task.reload.title
  end

  test "destroy removes the current user's task" do
    assert_difference "Task.count", -1 do
      delete list_task_url(@list, @task)
    end

    assert_redirected_to list_url(@list)
    assert_not Task.exists?(@task.id)
  end

  test "destroy of another user's task returns not found" do
    assert_no_difference "Task.count" do
      delete list_task_url(@other_list, @other_task)
    end

    assert_response :not_found
    assert Task.exists?(@other_task.id)
  end

  test "destroy as json responds with no content" do
    delete list_task_url(@list, @task, format: :json)

    assert_response :no_content
  end

  test "destroy as turbo stream redirects to the list" do
    delete list_task_url(@list, @task), headers: TURBO_STREAM_HEADERS

    assert_response :see_other
    assert_redirected_to list_url(@list)
  end

  test "list show renders its tasks and the inline quick add form" do
    get list_url(@list)

    assert_response :success
    assert_select "ul#tasks li.task-card", 1
    assert_select "ul#tasks li.task-card", text: /#{Regexp.escape(@task.title)}/
    assert_select "form[action=?]", list_tasks_path(@list)
    assert_select "input[name=?]", "task[title]"
  end

  test "list show renders the edit link targeting the task frame" do
    get list_url(@list)

    assert_response :success
    assert_select "turbo-frame#task_#{@task.id}_frame"
    assert_select "a[href=?][data-turbo-frame=?]", edit_list_task_path(@list, @task), "task_#{@task.id}_frame"
  end

  test "list show does not render other lists' tasks" do
    get list_url(@list)

    assert_response :success
    assert_not_includes response.body, @other_task.title
  end

  test "list show renders an empty state when the list has no tasks" do
    @task.destroy

    get list_url(@list)

    assert_response :success
    assert_select "ul#tasks .task-list__empty"
    assert_select "ul#tasks li.task-card", 0
  end
end
