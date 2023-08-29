# frozen_string_literal: true

require 'logger'
logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))

last_ten_years = (2012..2023)
students_per_class = rand(20..40)

logger.tagged('STUDENTS') { logger.info 'Creating Students' }
students = FactoryBot.create_list :student, 300

logger.tagged('SUBJECTS') { logger.info 'Creating Subjects' }
subjects = FactoryBot.create_list :subject, 7

logger.tagged('TEACHERS') { logger.info 'Creating Teachers' }
teachers = FactoryBot.create_list :teacher, 25

class_names = (5..9) # nth grade

last_ten_years.each do |year|
  class_names.each do |n|
    logger.tagged("YEAR=#{year}") { logger.info "Creating Classes for #{n}th grade" }
    course = FactoryBot.create(:course, year:, name: "#{n}th grade")
    course_teachers = teachers.sample(subjects.size).zip(subjects)

    course_teachers.each do |teacher, subject|
      FactoryBot.create(:teacher_assignment, course:, subject:, teacher:)

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
