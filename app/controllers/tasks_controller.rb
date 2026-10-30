class TasksController < ApplicationController
  before_action :set_list, except: %i[ index ]
  before_action :set_task, only: %i[ show edit update destroy ]

  def index
    @pagy, @active_tasks = pagy(:offset, current_user.tasks.active.includes(:list).ordered)
    @done_pagy, @done_tasks = pagy(:offset, current_user.tasks.completed.includes(:list).ordered, page_key: "done_page")
  end

  def show
  end

  def new
    @task = @list.tasks.build(status: :todo, position: next_position)
  end

  def edit
  end

  def create
    @task = @list.tasks.build(task_params)
    @task.user = current_user
    @task.status = :todo if @task.status.blank?
    @task.position = next_position if @task.position.blank?

    respond_to do |format|
      if @task.save
        format.html { redirect_to list_path(@list), notice: "Task was successfully created." }
        format.turbo_stream { redirect_to list_path(@list), status: :see_other }
        format.json { render :show, status: :created, location: list_task_url(@list, @task) }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @task.errors, status: :unprocessable_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to list_path(@list), notice: "Task was successfully updated.", status: :see_other }
        format.turbo_stream { redirect_to list_path(@list), status: :see_other }
        format.json { render :show, status: :ok, location: list_task_url(@list, @task) }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @task.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_to list_path(@list), notice: "Task was successfully destroyed.", status: :see_other }
      format.turbo_stream { redirect_to list_path(@list), status: :see_other }
      format.json { head :no_content }
    end
  end

  def reorder
    task_ids = params.expect(task_ids: []).filter_map { |id| Integer(id, exception: false) }
    tasks = @list.tasks.where(id: task_ids).index_by(&:id)
    # Keep the new positions inside the range the posted tasks already occupy
    # (a drag & drop only reorders the tasks visible on the current page, and
    # must not shuffle the tasks of the other pages).
    base_position = tasks.values.filter_map(&:position).min.to_i

    Task.transaction do
      task_ids.filter_map { |id| tasks[id] }.each_with_index do |task, index|
        task.update!(position: base_position + index)
      end
    end

    respond_to do |format|
      format.html { redirect_to list_path(@list), notice: "Tasks were successfully reordered." }
      format.json { head :no_content }
    end
  end

  private

  def set_list
    @list = current_user.lists.find(params.expect(:list_id))
  end

  def set_task
    @task = @list.tasks.find(params.expect(:id))
  end

  def task_params
    params.expect(task: [ :title, :description, :status, :position, :due_date ])
  end

  def next_position
    @list.tasks.maximum(:position).to_i + 1
  end
end
