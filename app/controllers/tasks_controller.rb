class TasksController < ApplicationController
  before_action :set_list, except: %i[ index ]
  before_action :set_task, only: %i[ show edit update destroy ]

  def index
    @tasks = current_user.tasks.includes(:list).ordered
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
