require "test_helper"

class LayoutStylesTest < ActionView::TestCase
  setup do
    controller.class.include CurrentUser
    controller.class.view_paths = [
      Rails.root.join("test/fixtures/templates"),
      Rails.root.join("app/views")
    ]
  end

  test "links every main component stylesheet" do
    output = render template: "slim_page", layout: "layouts/application"

    %w[00_tokens 10_layout 20_side_menu 30_forms 40_task_list 50_user_profile].each do |stylesheet|
      assert_match %r{/assets/#{stylesheet}-[0-9a-f]+\.css}, output
    end
  end

  test "renders the application shell with the side menu and profile" do
    render template: "slim_page", layout: "layouts/application"

    assert_select "div.app-shell"
    assert_select "aside.app-sidebar nav.side-menu"
    assert_select "nav.side-menu .side-menu__brand"
    assert_select "nav.side-menu ul.side-menu__nav li a.side-menu__link"
    assert_select "nav.side-menu .user-profile"
    assert_select "nav.side-menu .user-profile .user-profile__avatar"
    assert_select "main.app-main h1", text: "Slim page"
  end
end
