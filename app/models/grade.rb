# frozen_string_literal: true

class Grade < ApplicationRecord
  validates :value, presence: true,
                    numericality: { in: 0.0..10.0 }

  belongs_to :exam
  belongs_to :enrollment, foreign_key: :enrollment_code, inverse_of: :grades

  scope :averages, lambda {
    select('AVG(grades.value) AS average')
  }

  scope :by_student, lambda { |id|
    joins(enrollment: :student)
      .where(student: { id: })
      .select('student.name AS student_name', 'student.born_on AS student_born_on')
      .group('student.id')
  }

  scope :by_year, lambda { |year|
    joins(enrollment: :course)
      .where("courses.year = #{year}")
      .select('courses.year')
      .group('courses.year')
  }

  scope :grouped_by_subjects, lambda {
    joins(exam: :subject)
      .select('subjects.name AS subject_name')
      .group('subjects.name')
  }

  scope :grouped_by_courses, lambda {
    joins(enrollment: :course)
      .select('course.name AS course_name')
      .group('course.name')
  }

  scope :grouped_by_enrollments, lambda {
    joins(:enrollment)
      .select('enrollments.code AS enrollment_code')
      .group('enrollments.code')
  }

  scope :best_value, lambda {
    select('MAX(grades.value) AS best_grade')
  }

  scope :grouped_by_students, lambda {
    joins(enrollment: :student)
      .select('students.name AS student_name')
      .group('students.id')
  }

  scope :grouped_by_subjects, lambda {
    joins(exam: :subject)
      .select('subjects.name AS subject_name')
      .group('subjects.id')
  }

  scope :grouped_by_courses, lambda {
    joins(enrollment: :course)
      .select('courses.name AS course_name', 'courses.year')
      .group('courses.id')
  }

  scope :best_values_by_subject, lambda { |year:|
    joins(enrollment: :course, exam: :subject)
      .best_value
      .grouped_by_courses
      .grouped_by_subjects
      .grouped_by_students
      .where("(subjects.name, grades.value, courses.year) IN (#{Exam.best_grades_per_subject.grouped_by_year.to_sql})")
      .by_year(year)
      .order('subjects.name ASC')
  }
end
