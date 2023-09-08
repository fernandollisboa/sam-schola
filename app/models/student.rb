# frozen_string_literal: true

class Student < ApplicationRecord
  validates :name, presence: true
  validates :born_on, presence: true,
                      comparison: { less_than: proc { Time.zone.today } }

  has_many :enrollments, dependent: :destroy
  has_many :grades, through: :enrollments
  has_many :courses, through: :enrollments

  scope :select_basic_fields, lambda {
    select(:id, :name, :born_on)
  }

  scope :youngest_by_course, lambda {
    select_basic_fields
      .joins(enrollments: :course)
      .select(
        'courses.name AS course_name',
        'courses.year AS course_year'
      ).group('courses.name', 'courses.year', :id)
      .where(born_on: Course.youngest_students)
  }

  scope :order_by_course_name, lambda {
    joins(enrollments: :course)
      .order('courses.name DESC')
  }

  scope :enrolled_courses, lambda {
    joins(enrollments: :course)
      .select(
        'enrollments.code AS enrollment_code',
        'courses.name AS course_name'
      )
  }

  scope :by_year, lambda { |year|
    joins(enrollments: :course)
      .where(courses: { year: })
      .select('courses.year AS course_year')
  }

  scope :yearly_reports, lambda { |year:|
    joins(enrollments: [:course])
      .where(courses: { year: })
      .select(
        :id,
        :name,
        :born_on,
        'courses.year AS course_year',
        'enrollments.code AS enrollment_code',
        'courses.name AS course_name'
      )
      .distinct
  }

  scope :grade_averages, lambda {
    joins(enrollments: [:grades])
      .select('AVG(grades.value) AS grades_average')
      .group('enrollments.code', 'courses.name', 'students.id', 'courses.year')
  }
end
