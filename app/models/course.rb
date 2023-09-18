# frozen_string_literal: true

class Course < ApplicationRecord
  validates :name, presence: true,
                   uniqueness: { scope: :year }
  validates :year, presence: true,
                   numericality: { only_integer: true, greater_than: 2000 }
  validates :starts_on, presence: true
  validates :ends_on, presence: true,
                      comparison: { greater_than: :starts_on }

  has_many :teacher_assignments, dependent: :destroy
  has_many :teachers, through: :teacher_assignments
  has_many :enrollments, dependent: :destroy

  scope :select_basic_fields, lambda {
    select(:name, :year)
  }
  scope :by_year, lambda { |year|
    where(year:)
  }

  scope :enrollments, lambda {
    joins(:enrollments)
      .group(:name, :year)
  }

  scope :enrollments_count, lambda {
    enrollments.select('COUNT(enrollments.code) AS enrollments_count')
  }

  scope :youngest_students, lambda {
    joins(enrollments: :student)
      .select('MAX(students.born_on) AS max_born_on')
      .group(:id)
  }
end
