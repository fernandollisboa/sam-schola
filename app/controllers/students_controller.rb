# frozen_string_literal: true

class StudentsController < ApplicationController
  before_action :set_student, only: %i[edit update destroy]
  before_action :set_year, only: %i[index show]

  def index
    @students = Student.select_basic_fields.enrolled_courses.by_year(year)

    return unless @students.empty?

    flash[:notice] = "No Enrollments for the Current Year (#{year})"
  end

  def show
    @grades = FindStudentGradesAverages.call(student_id: params[:id], year: @year)

    if @grades.empty?
      flash[:notice] = "No Enrollment for the Current Year (#{year})"
      set_student
    else
      enrollment = @grades.take.enrollment

      @student = enrollment.student
      @enrollment_code = enrollment.code
      @course_name = @grades.take.course_name
    end
  end

  def new
    @student = Student.new
  end

  def edit; end

  def create
    @student = Student.new(student_params)

    if @student.save
      redirect_to @student, notice: I18n.t('flash.student.success.create')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @student.update(student_params)
      redirect_to @student, notice: I18n.t('flash.student.success.update'), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to students_url, notice: I18n.t('flash.student.success.destroy'), status: :see_other
  end

  private

  attr_reader :year

  def set_student
    @student = Student.find(params[:id])
  end

  def set_year
    @year = params[:year] || Date.current.year
  end

  def student_params
    params.require(:student).permit(:name, :born_on)
  end
end
