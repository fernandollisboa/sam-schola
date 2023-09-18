# frozen_string_literal: true

class Teacher < ApplicationRecord
  validates :name, presence: true

  has_many :teacher_assignments, dependent: :destroy
  has_many :courses, through: :teacher_assignments
  has_many :subjects, through: :teacher_assignments

  scope :grouped_by_name, lambda {
    select(:name)
      .group(:name)
  }

  scope :top_overloaded, lambda { |year:|
    joins(teacher_assignments: [course: [enrollments: :student]])
      .select('COUNT(students.id) AS student_count')
      .grouped_by_name
      .where("courses.year = #{year}")
  }
end
