class Api::V1::CoursesController < ApplicationController
  before_action :set_course, only: %i[ show update destroy add_ta view_tas remove_ta copy ]
  rescue_from ActiveRecord::RecordNotFound, with: :course_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  def action_allowed?
    has_privileges_of?('Instructor')
  end

  # GET /courses
  # List all the courses
  def index
    courses = Course.all
    render json: courses, status: :ok
  end

  # GET /courses/1
  # Get a course
  def show
    render json: @course, status: :ok
  end

  # POST /courses
  # Create a course
  def create
    course = Course.new(course_params)
    if course.save
      render json: course, status: :created
    else
      render json: course.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /courses/1
  # Update a course
  def update
    if @course.update(course_params)
      render json: @course, status: :ok
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  # DELETE /courses/1
  # Delete a course
  def destroy
    @course.destroy
    render json: { message: I18n.t('course.deleted', id: params[:id]) }, status: :no_content
  end

  # Adds a Teaching Assistant to the course
  def add_ta
    user = User.find_by(id: params[:ta_id])
    result = @course.add_ta(user)
    if result[:success]
      render json: result[:data], status: :created
    else
      render json: { status: "error", message: result[:message] }, status: :bad_request
    end
  end

  # Displays all Teaching Assistants for the course
  def view_tas
    teaching_assistants = @course.tas
    render json: teaching_assistants, status: :ok
  end

  # Removes Teaching Assistant from the course
  def remove_ta
    result = @course.remove_ta(params[:ta_id])
    if result[:success]
      render json: { message: I18n.t('course.ta_removed', ta_name: result[:ta_name]) }, status: :ok
    else
      render json: { status: "error", message: result[:message] }, status: :not_found
    end
  end

  # Creates a copy of the course
  def copy
    # existing_course = Course.find(params[:id])
    success = @course.copy_course
    if success
      render json: { message: I18n.t('course.copy_success', name: @course.name) }, status: :ok
    else
      render json: { message: I18n.t('course.copy_failure') }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    @course = Course.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def course_params
    params.require(:course).permit(:name, :directory_path, :info, :private, :instructor_id, :institution_id)
  end

  def course_not_found
    render json: { error: I18n.t('course.not_found', id: params[:id]) }, status: :not_found
  end

  def parameter_missing
    render json: { error: I18n.t('course.parameter_missing') }, status: :unprocessable_entity
  end
end
