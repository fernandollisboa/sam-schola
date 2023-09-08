# frozen_string_literal: true

class Exam < ApplicationRecord
  validates :realized_on, presence: true

  belongs_to :course
  belongs_to :subject

  has_many :grades, dependent: :destroy
  has_many :enrollments, through: :grades

  scope :best_grades_per_subject, lambda {
    joins(:grades, :subject, enrollments: :course)
      .select(
        'subjects.name AS subject_name',
        'MAX(grades.value) AS best_grade'
      )
      .group('subjects.id', 'courses.year')
  }

  scope :grouped_by_year, lambda {
    joins(enrollments: :course)
      .select('courses.year')
      .group('courses.year')
  }
end
