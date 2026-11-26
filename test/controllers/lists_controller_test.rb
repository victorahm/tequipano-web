require "test_helper"

class ListsControllerTest < ActionDispatch::IntegrationTest
  TURBO_STREAM_HEADERS = { "ACCEPT" => "text/vnd.turbo-stream.html, text/html, application/xhtml+xml" }.freeze

  setup do
    @current_user = users(:one)
    @list = List.find_by!(user: @current_user)
    @original_name = @list.name
    @other_list = List.where.not(user: @current_user).first
    @other_user = @other_list.user
    log_in_as @current_user
  end

  test "index renders only the current user's lists" do
    get lists_url

    assert_response :success
    assert_select "h1.app-main__title", "Lists"
    assert_select "a[href=?]", new_list_path
    assert_select "ul#lists li.task-card", 1
    assert_select "ul#lists li.task-card", text: /#{Regexp.escape(@list.name)}/
    assert_not_includes response.body, @other_list.name
  end

  test "index renders an empty state when the user has no lists" do
    List.where(user: @current_user).destroy_all

    get lists_url

    assert_response :success
    assert_select "ul#lists .task-list__empty"
    assert_select "ul#lists li.task-card", 0
    assert_select "nav.pagy.series-nav", 0
  end

  test "index paginates lists in pages of 25 with navigation" do
    create_extra_lists(25)

    get lists_url

    assert_response :success
    assert_select "ul#lists li.task-card", 25
    assert_select "nav.pagy.series-nav[aria-label=?]", "Lists pages"
    assert_select "nav.pagy.series-nav a[href=?]", "/lists?page=2&limit=25"

    get lists_url(page: 2)

    assert_response :success
    assert_select "ul#lists li.task-card", 1
    assert_select "nav.pagy.series-nav a[href=?]", "/lists?page=1&limit=25"
  end

  test "index renders no navigation when everything fits on one page" do
    get lists_url

    assert_response :success
    assert_select "ul#lists li.task-card", 1
    assert_select "nav.pagy.series-nav", 0
  end

  test "index renders an empty page beyond the last one without the empty state" do
    create_extra_lists(25)

    get lists_url(page: 99)

    assert_response :success
    assert_select "ul#lists li.task-card", 0
    assert_select "ul#lists .task-list__empty", 0
    assert_select "nav.pagy.series-nav"
  end

  test "index as json renders only the current user's lists" do
    get lists_url(format: :json)

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal [ @list.id ], payload.map { |list| list["id"] }
  end

  test "side menu shows a submenu with the current user's lists" do
    get lists_url

    assert_response :success
    assert_select "aside .side-menu__subnav li a", 1
    assert_select "aside .side-menu__subnav a[href=?]", list_path(@list)
  end

  test "side menu shows at most 5 lists in the submenu" do
    create_extra_lists(5)

    get lists_url

    assert_response :success
    assert_select "aside .side-menu__subnav a[href^=?]", "/lists/", 5
    assert_select "aside .side-menu__subnav li a", { count: 1, text: /Extra list 4/ }
    assert_select "aside .side-menu__subnav li a", { count: 0, text: /Extra list 5/ }
  end

  test "side menu renders a More lists link when the user has more than 5 lists" do
    create_extra_lists(5)

    get lists_url

    assert_response :success
    assert_select "aside .side-menu__subnav li a", { count: 1, text: "More lists", href: lists_path }
    assert_select "aside .side-menu__subnav a[href=?].is-active", lists_path, count: 0
  end

  test "side menu does not render a More lists link with 5 or fewer lists" do
    get lists_url

    assert_response :success
    assert_select "aside .side-menu__subnav a", { count: 0, text: "More lists" }

    create_extra_lists(4)

    get lists_url

    assert_select "aside .side-menu__subnav a[href^=?]", "/lists/", 5
    assert_select "aside .side-menu__subnav a", { count: 0, text: "More lists" }
  end

  test "side menu marks the open list in the submenu" do
    get list_url(@list)

    assert_response :success
    assert_select ".side-menu__subnav a[href=?].is-active", list_path(@list)
  end

  test "show renders the current user's list" do
    get list_url(@list)

    assert_response :success
    assert_select "h1.app-main__title", @list.name
    assert_select "a[href=?]", edit_list_path(@list)
  end

  test "show paginates active tasks with navigation" do
    create_tasks(@list, 25)

    get list_url(@list)

    assert_response :success
    assert_select "ul#tasks li.task-card", 25
    assert_select "nav.pagy.series-nav[aria-label=?]", "Task pages"
    assert_select "nav.pagy.series-nav a[href=?]", "/lists/#{@list.id}?page=2&limit=25"

    get list_url(@list, page: 2)

    assert_response :success
    assert_select "ul#tasks li.task-card", 1
    assert_select "nav.pagy.series-nav a[href=?]", "/lists/#{@list.id}?page=1&limit=25"
  end

  test "show paginates the done section independently" do
    create_tasks(@list, 26, status: "done")

    get list_url(@list)

    assert_response :success
    assert_select "details.task-done summary", "Done (26)"
    assert_select "details.task-done ul.task-list li.task-card", 25
    assert_select "details.task-done nav.pagy.series-nav[aria-label=?]", "Done task pages"
    assert_select "details.task-done nav.pagy.series-nav a[href=?]", "/lists/#{@list.id}?done_page=2&limit=25"

    get list_url(@list, done_page: 2)

    assert_response :success
    assert_select "details.task-done ul.task-list li.task-card", 1
    assert_select "ul#tasks li.task-card", 1
  end

  test "show as json renders the list" do
    get list_url(@list, format: :json)

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal @list.id, payload["id"]
    assert_equal @list.name, payload["name"]
  end

  test "show of another user's list returns not found" do
    get list_url(@other_list)

    assert_response :not_found
  end

  test "new renders the list form" do
    get new_list_url

    assert_response :success
    assert_select "form[action=?]", lists_path
    assert_select "input[name=?]", "list[name]"
    assert_select "input[name=?]", "list[color]"
    assert_select "input[name=?]", "list[position]"
  end

  test "create saves a list owned by the current user" do
    assert_difference "List.count", 1 do
      post lists_url, params: { list: { name: "Sprint 1", color: "#ff0000", position: 9 } }
    end

    created = List.order(:id).last
    assert_redirected_to list_url(created)
    assert_equal @current_user, created.user
    assert_equal "Sprint 1", created.name
  end

  test "create ignores a forged user_id" do
    post lists_url, params: { list: { name: "Forged", color: "#00ff00", position: 3, user_id: @other_user.id } }

    assert_equal @current_user, List.find_by!(name: "Forged").user
  end

  test "create with invalid data renders the form with errors" do
    assert_no_difference "List.count" do
      post lists_url, params: { list: { name: "", color: "", position: "" } }
    end

    assert_response :unprocessable_content
    assert_select ".form__group--error .form__error", minimum: 1
  end

  test "create as json responds with created" do
    post lists_url(format: :json), params: { list: { name: "API list", color: "#123456", position: 1 } }

    assert_response :created
    payload = JSON.parse(response.body)
    assert_equal "API list", payload["name"]
    assert_equal @current_user.id, payload["user_id"]
  end

  test "create as json with invalid data responds with unprocessable" do
    post lists_url(format: :json), params: { list: { name: "" } }

    assert_response :unprocessable_content
    assert JSON.parse(response.body).key?("name")
  end

  test "create as turbo stream redirects to the created list" do
    post lists_url, params: { list: { name: "Stream list", color: "#abcdef", position: 1 } },
      headers: TURBO_STREAM_HEADERS

    assert_response :see_other
    assert_redirected_to list_url(List.find_by!(name: "Stream list"))
  end

  test "create as turbo stream with invalid data renders the form with errors" do
    post lists_url, params: { list: { name: "" } },
      headers: TURBO_STREAM_HEADERS

    assert_response :unprocessable_content
    assert_select ".form__group--error .form__error", minimum: 1
  end

  test "edit renders the list form" do
    get edit_list_url(@list)

    assert_response :success
    assert_select "form[action=?]", list_path(@list)
    assert_select "input[name=?][value=?]", "list[name]", @list.name
  end

  test "edit of another user's list returns not found" do
    get edit_list_url(@other_list)

    assert_response :not_found
  end

  test "update changes the list attributes" do
    patch list_url(@list), params: { list: { name: "Renamed", color: "#fedcba", position: 4 } }

    assert_redirected_to list_url(@list)
    @list.reload
    assert_equal "Renamed", @list.name
    assert_equal "#fedcba", @list.color
    assert_equal 4, @list.position
    assert_equal @current_user, @list.user
  end

  test "update with invalid data renders the form with errors" do
    patch list_url(@list), params: { list: { name: "" } }

    assert_response :unprocessable_content
    assert_select ".form__group--error .form__error", minimum: 1
    assert_equal @original_name, @list.reload.name
  end

  test "update as json responds with ok" do
    patch list_url(@list, format: :json), params: { list: { name: "Renamed via JSON" } }

    assert_response :success
    assert_equal "Renamed via JSON", JSON.parse(response.body)["name"]
  end

  test "update as turbo stream redirects to the list" do
    patch list_url(@list), params: { list: { name: "Stream renamed" } },
      headers: TURBO_STREAM_HEADERS

    assert_response :see_other
    assert_redirected_to list_url(@list)
    assert_equal "Stream renamed", @list.reload.name
  end

  test "update of another user's list returns not found" do
    patch list_url(@other_list), params: { list: { name: "Hijacked" } }

    assert_response :not_found
    assert_equal @other_list.reload.name, @other_list.name
    assert_not_equal "Hijacked", @other_list.name
  end

  test "destroy removes the current user's list" do
    assert_difference "List.count", -1 do
      delete list_url(@list)
    end

    assert_redirected_to lists_url
    assert_not List.exists?(@list.id)
  end

  test "destroy of another user's list returns not found" do
    assert_no_difference "List.count" do
      delete list_url(@other_list)
    end

    assert_response :not_found
    assert List.exists?(@other_list.id)
  end

  test "destroy as json responds with no content" do
    delete list_url(@list, format: :json)

    assert_response :no_content
  end

  test "destroy as turbo stream redirects to the index" do
    delete list_url(@list), headers: TURBO_STREAM_HEADERS

    assert_response :see_other
    assert_redirected_to lists_url
    assert_not List.exists?(@list.id)
  end

  private
    def create_extra_lists(count)
      count.times do |i|
        List.create!(user: @current_user, name: "Extra list #{i + 1}", color: "#123456", position: 100 + i)
      end
    end

    def create_tasks(list, count, status: "todo")
      count.times do |i|
        list.tasks.create!(title: "Task #{i + 1}", user: list.user, status: status, position: 100 + i)
      end
    end
end
