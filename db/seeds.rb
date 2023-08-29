# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

last_ten_years = (2012..2023)
students_per_class = rand(20..40)

students = FactoryBot.create_list :student, 20
subjects = FactoryBot.create_list :subject, 7
teachers = FactoryBot.create_list :teacher, 100

class_names = (5..9) # nth grade

last_ten_years.each do |year|
  class_names.each do |n|
    course = FactoryBot.create(:course, year:, name: "#{n}th grade")

    course_teachers = teachers.sample(subjects.size).zip(subjects)
    course_teachers.each do |teacher, subject|
      TeacherAssignment.create(course:, subject:, teacher:)

      students.take(students_per_class).each do |student|
        enrollment = FactoryBot.create(:enrollment, student:, course:)

        quantity_of_exams = year == 2023 ? 4 : 8
        quantity_of_exams.times do
          exam = FactoryBot.create(:exam, course:, subject:)
          FactoryBot.create(:grade, enrollment:, exam:)
        end
      end
    end
  end
end
