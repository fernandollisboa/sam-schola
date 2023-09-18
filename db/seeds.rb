# frozen_string_literal: true

require 'logger'
logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))

last_ten_years = (2012..2023)
quantity_of_students_per_class = (20..40)

logger.tagged('STUDENTS') { logger.info 'Creating Students' }
students = FactoryBot.create_list :student, 300

logger.tagged('SUBJECTS') { logger.info 'Creating Subjects' }
subjects = FactoryBot.create_list :subject, 7

logger.tagged('TEACHERS') { logger.info 'Creating Teachers' }
teachers = FactoryBot.create_list :teacher, 25

def create_enrollments(course:, course_students:)
  course_students.map do |student|
    FactoryBot.create(:enrollment, student:, course:)
  end
end

def create_exams_and_grades(enrollment:, course:, subject:)
  quantity_of_exams = course.year == 2023 ? 4 : 8
  quantity_of_exams.times do
    exam = FactoryBot.create(:exam, course:, subject:)
    FactoryBot.create(:grade, enrollment:, exam:)
  end
end

class_names = (5..9) # nth grade

last_ten_years.each do |year|
  class_names.each do |n|
    course = FactoryBot.create(:course, year:, name: "#{n}th grade")
    logger.tagged("YEAR=#{year}") { logger.info "Creating Classes for #{n}th grade" }

    teacher_subject_hash = teachers.sample(subjects.size).zip(subjects)
    teacher_subject_hash.each do |teacher, subject|
      FactoryBot.create(:teacher_assignment, course:, subject:, teacher:)

      logger.tagged("YEAR=#{year}","#{n}th Grade") do
       logger.info "Creating classes for #{subject.name} with teacher #{teacher.name}"
      end

      course_students = students.take(rand(quantity_of_students_per_class))
      course_enrollments = create_enrollments(course:, course_students:)
      course_enrollments.each do |enrollment|
        create_exams_and_grades(enrollment:, course:, subject:)
      end
    end
  end
end
