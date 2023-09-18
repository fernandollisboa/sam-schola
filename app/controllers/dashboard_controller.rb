# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :set_year, only: [:show]

  def show
    @enrollments_by_course = Course.select_basic_fields.enrollments_count.by_year(year).order(name: :desc)
    @youngest_student_by_course = Student.youngest_by_course.by_year(year).order_by_course_name
    @best_grades_by_subject =  Grade.best_values_by_subject(year:)
    @top_overloaded_teachers = Teacher.top_overloaded(year:)
  end

  private

  attr_reader :year

  def set_year
    @year = params[:year] || Time.current.year
  end
end
