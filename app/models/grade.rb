# frozen_string_literal: true

class Grade < ApplicationRecord
  validates :value, presence: true,
                    numericality: { in: 0.0..10.0 }

  belongs_to :exam
  belongs_to :enrollment, foreign_key: :enrollment_code, inverse_of: :grades
end
