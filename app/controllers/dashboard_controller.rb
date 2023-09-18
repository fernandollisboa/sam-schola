class DashboardController < ApplicationController
  before_action :set_year, only: [:show]

  def show
    @enrollments_by_course = []
    @youngest_student_by_course = []
    @best_grades_by_subject = []
    @top_overloaded_teachers = []
  end

  private

  def set_year
    @year = params[:year] || Time.current.year
  end
end
