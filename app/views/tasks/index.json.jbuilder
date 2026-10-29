json.active do
  json.array! @active_tasks, partial: "tasks/task", as: :task
end
json.done do
  json.array! @done_tasks, partial: "tasks/task", as: :task
end
