require "test_helper"

class PagyTest < ActiveSupport::TestCase
  test "includes the pagy method in controllers" do
    assert_includes ApplicationController.ancestors, Pagy::Method
  end

  test "paginates a collection" do
    pagy, records = paginate((1..25).to_a, page: 2, limit: 10)

    assert_equal 2, pagy.page
    assert_equal 3, pagy.last
    assert_equal 10, pagy.offset
    assert_equal (11..20).to_a, records
  end

  test "reads the page from the request params" do
    _pagy, records = paginate((1..25).to_a, limit: 10, query_string: "page=3")

    assert_equal (21..25).to_a, records
  end

  test "renders navigation links" do
    pagy, = paginate((1..45).to_a, page: 2, limit: 10)

    html = pagy.series_nav(aria_label: "Pages")

    assert_includes html, %(<nav class="pagy series-nav" aria-label="Pages">)
    assert_includes html, %(rel="prev")
    assert_includes html, %(rel="next")
    assert_includes html, "page=1"
    assert_includes html, "page=3"
  end

  test "serves an empty page beyond the last one" do
    pagy, records = paginate((1..5).to_a, page: 4, limit: 10)

    assert_equal 1, pagy.last
    assert_empty records
  end

  private
    def paginate(collection, query_string: "", **options)
      request = ActionDispatch::TestRequest.create("QUERY_STRING" => query_string)
      controller = ApplicationController.new
      controller.set_request!(request)
      controller.set_response!(ActionDispatch::TestResponse.new)
      controller.send(:pagy, :offset, collection, **options)
    end
end
