require "test_helper"

class SlimRenderingTest < ActionView::TestCase
  setup do
    controller.class.view_paths = [
      Rails.root.join("test/fixtures/templates"),
      Rails.root.join("app/views")
    ]
  end

  test "renders slim templates" do
    template = lookup_context.find_template("slim_example")

    assert_match(/\.slim\z/, template.identifier)
    assert_not_instance_of ActionView::Template::Handlers::Raw, template.handler

    output = render template: "slim_example"

    assert_select "h1", text: "Slim example"
    assert_select "ul li", text: "one", count: 1
    assert_select "ul li", count: 3
    assert_no_match(/\.each do \|item\|/, output)
  end

  test "renders the application layout as slim" do
    layout = lookup_context.find_template("application", [ "layouts" ])

    assert_match(/\.slim\z/, layout.identifier)

    render template: "slim_page", layout: "layouts/application"

    assert_select "title", text: "Tequipano Web"
    assert_select "head meta[name=viewport]"
    assert_select "body h1", text: "Slim page"
    assert_select "link[rel=stylesheet]"
    assert_select "script[type=importmap]"
  end
end
