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
end
