module ApplicationHelper
  ICONS = {
    show: [
      "M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z",
      "M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z"
    ],
    edit: [
      "M12 20h9",
      "M16.5 3.5a2.1 2.1 0 0 1 3 3L7.5 18.5 3 20l1.5-4.5L16.5 3.5Z"
    ],
    new: [
      "M12 5v14",
      "M5 12h14"
    ],
    delete: [
      "M3 6h18",
      "M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2",
      "M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6",
      "M10 11v6",
      "M14 11v6"
    ],
    done: [
      "M20 6 9 17l-5-5"
    ],
    drag: [
      "M9 5h.01",
      "M9 12h.01",
      "M9 19h.01",
      "M15 5h.01",
      "M15 12h.01",
      "M15 19h.01"
    ]
  }.freeze

  def ui_icon(name, **options)
    paths = ICONS.fetch(name.to_sym) { raise ArgumentError, "Unknown icon: #{name}" }

    tag.svg(
      **options.merge(
        viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
        "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round",
        "aria-hidden": "true", focusable: "false"
      )
    ) do
      safe_join(paths.map { |path| tag.path(d: path) })
    end
  end

  def user_initials(user)
    user.name.to_s.split.map { |word| word[0] }.first(2).join.upcase
  end
end
