class ListsController < ApplicationController
  before_action :set_list, only: %i[ show edit update destroy ]

  def index
    @pagy, @lists = pagy(:offset, current_user.lists.includes(:tasks).order(:position, :id))
  end

  def show
    @tasks = @list.tasks.ordered
    @new_task = @list.tasks.build
  end

  def new
    @list = current_user.lists.build(color: List::DEFAULT_COLOR, position: next_position)
  end

  def edit
  end

  def create
    @list = current_user.lists.build(list_params)

    respond_to do |format|
      if @list.save
        format.html { redirect_to @list, notice: "List was successfully created." }
        format.turbo_stream { redirect_to @list, status: :see_other }
        format.json { render :show, status: :created, location: @list }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @list.errors, status: :unprocessable_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @list.update(list_params)
        format.html { redirect_to @list, notice: "List was successfully updated.", status: :see_other }
        format.turbo_stream { redirect_to @list, status: :see_other }
        format.json { render :show, status: :ok, location: @list }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @list.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @list.destroy

    respond_to do |format|
      format.html { redirect_to lists_path, notice: "List was successfully destroyed.", status: :see_other }
      format.turbo_stream { redirect_to lists_path, status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_list
    @list = current_user.lists.find(params.expect(:id))
  end

  def list_params
    params.expect(list: [ :name, :color, :position ])
  end

  def next_position
    current_user.lists.maximum(:position).to_i + 1
  end
end
