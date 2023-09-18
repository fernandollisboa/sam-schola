# frozen_string_literal: true

class Grade < ApplicationRecord
  validates :value, presence: true,
                    numericality: { in: 0.0..10.0 }

  belongs_to :exam
  belongs_to :enrollment, foreign_key: :enrollment_code, inverse_of: :grades

  scope :yearly_averages_by_subject, lambda { |year:|
    joins(enrollment: %i[student course], exam: [:subject])
      .where(course: { year: })
      .select(
        'subjects.name AS subject_name',
        'enrollments.code AS enrollment_code',
        'enrollments.code AS code',
        'student.name AS student_name',
        'student.born_on AS student_born_on',
        'course.year',
        'AVG(grades.value) AS average',
        'course.name AS course_name'
      ).group(
        'course.year',
        'subjects.name',
        'student.name',
        'student.born_on',
        'enrollments.code',
        'course.name'
      )
  }

  scope :find_by_student_id, lambda { |id:|
    joins(enrollment: :student)
      .where(student: { id: })
  }
end
