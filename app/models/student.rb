# frozen_string_literal: true

class Student < ApplicationRecord
  validates :name, presence: true
  validates :born_on, presence: true,
                      comparison: { less_than: proc { Time.zone.today } }

  has_many :enrollments, dependent: :destroy
  has_many :grades, through: :enrollments

  scope :yearly_reports, ->(year:) do
    joins(enrollments: [:course])
    .where(courses: { year: } )
    .select(
      :id,
      :name,
      :born_on,
      'courses.year AS course_year',
      'enrollments.code AS enrollment_code',
      'courses.name AS course_name',
    )
    .distinct
  end

  scope :grade_averages, -> do
    joins(enrollments: [:grades])
    .select("AVG(grades.value) AS grades_average")
    .group('enrollments.code', 'courses.name', 'students.id', "courses.year")
  end
end
