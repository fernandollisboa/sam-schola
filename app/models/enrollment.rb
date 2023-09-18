# frozen_string_literal: true

class Enrollment < ApplicationRecord
  validates :code, presence: true,
                   uniqueness: true

  belongs_to :student
  belongs_to :course
  has_many :grades, dependent: :destroy, foreign_key: :enrollment_code, inverse_of: :enrollment

  scope :find_by_year, lambda { |year:|
    joins(:course)
      .where(course: { year: })
  }
end
