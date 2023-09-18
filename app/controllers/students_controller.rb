# frozen_string_literal: true

class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]
  before_action :set_year, only: %i[index, show]

  def index
    @students = Student.all
  end

  def show
    @student = Student.resume(id: params[:id], year: @year)
    .select(
      :id,
      :name,
      :born_on,
      "enrollments.code AS enrollment_code",
      "courses.name AS course_name",
      "AVG(grades.value) AS grades_average"
    ).first

    @grades = Grade.joins(enrollment: [:student, :course], exam: [:subject])
    .where(course: { year: @year }, student: { id: 1 })
    .select(
      'subjects.name AS subject_name',
      'enrollments.code AS enrollment_code',
      'enrollments.code AS code',
      'student.name AS student_name',
      'course.year',
      'AVG(grades.value) AS average',
      'course.name AS course_name'
    ).group('course.year', 'subjects.name', 'student.name', 'enrollments.code', 'course.name')


    @enrollment_code = @student&.enrollment_code
    @course_name = @student&.course_name
    @grades_average = @student&.grades_average

    if @student.nil?
      set_student
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
