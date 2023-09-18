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
      .where(course: { year: })
      .select('course.year')
      .group('course.year')
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

  scope :find_by_student_id, lambda { |id|
    joins(enrollment: :student)
      .where(student: { id: })
  }
end
