json.extract! task, :id, :title, :description, :status, :position, :completed_at, :due_date, :list_id, :user_id, :created_at, :updated_at
json.url list_task_url(task.list, task)
