# frozen-string-literal: true

class FindStudentGradesAverages < Query
  def initialize(student_id:, year:)
    @student_id = student_id
    @year = year
  end

  def call
    Grade.includes(enrollment: [:student])
         .averages
         .by_student(student_id)
         .by_year(year)
         .grouped_by_courses
         .grouped_by_subjects
         .grouped_by_enrollments
  end

  private

  attr_accessor :student_id, :year
end
