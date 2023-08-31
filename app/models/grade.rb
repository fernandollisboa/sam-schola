# frozen_string_literal: true

class Grade < ApplicationRecord
  validates :value, presence: true,
                    numericality: { in: 0.0..10.0 }

  belongs_to :exam
  belongs_to :enrollment, foreign_key: :enrollment_code, inverse_of: :grades

  scope :yearly_averages_by_subject, ->(year:) do
    joins(enrollment: [:student, :course], exam: [:subject])
    .where(course: { year: })
    .select(
      'subjects.name AS subject_name',
      'enrollments.code AS enrollment_code',
      'enrollments.code AS code',
      'student.name AS student_name',
      'course.year',
      'AVG(grades.value) AS average',
      'course.name AS course_name'
    ).group('course.year', 'subjects.name', 'student.name', 'enrollments.code', 'course.name')
  end

  scope :find_by_student_id, ->(id:) do
    where(student: { id: })
  end
end
