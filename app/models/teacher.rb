# frozen_string_literal: true

class Teacher < ApplicationRecord
  validates :name, presence: true

  has_many :teacher_assignments, dependent: :destroy
  has_many :courses, through: :teacher_assignments
  has_many :subjects, through: :teacher_assignments
end
