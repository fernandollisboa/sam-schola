# frozen_string_literal: true

require 'logger'
logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
started_on = Time.current

last_ten_years = (2012..2023)

logger.tagged('STUDENTS') { logger.info 'Creating Students' }
students = FactoryBot.create_list :student, 300

logger.tagged('SUBJECTS') { logger.info 'Creating Subjects' }
subjects = FactoryBot.create_list :subject, 7

logger.tagged('TEACHERS') { logger.info 'Creating Teachers' }
teachers = FactoryBot.create_list :teacher, 25

def random_student_count_per_class
  rand(20..40)
end

def create_enrollments(course_id:, students_ids:)
  enrollments = students_ids.map do |student_id|
    { code: SecureRandom.uuid, student_id:, course_id: }
  end
  Enrollment.insert_all enrollments
end

def create_exams_and_grades(enrollment_code:, course:, subject:)
  quantity_of_exams = course.year == 2023 ? 4 : 8

  exams_arr = Array.new(quantity_of_exams) { FactoryBot.attributes_for(:exam, course_id: course.id, subject_id: subject.id)}
  exams = Exam.insert_all exams_arr

  grades = exams.map do |exam|
    { exam_id: exam['id'], enrollment_code:, value: rand(0.0..10.0) }
  end
  Grade.insert_all grades
end

class_names = (5..9) # nth grade

last_ten_years.each do |year|
  class_names.each do |n|
    course = FactoryBot.create(:course, year:, name: "#{n}th grade")

    logger.tagged("YEAR=#{year}") { logger.info "Creating Classes for #{n}th grade" }

    teacher_subject_hash = teachers.sample(subjects.size).zip(subjects)

    teacher_assignments = []
    teacher_subject_hash.each do |teacher, subject|
      teacher_id = teacher.id
      course_id = course.id
      subject_id = subject.id

      teacher_assignments << { course_id:, subject_id:, teacher_id:}

      logger.tagged("YEAR=#{year}","#{n}th Grade") do
       logger.info "Creating classes for #{subject.name} with teacher #{teacher.name}"
      end

      students_ids = students.take(random_student_count_per_class).pluck(:id)
      course_enrollments = create_enrollments(course_id:, students_ids:)
      course_enrollments.map do |enrollment|
        create_exams_and_grades(enrollment_code: enrollment['code'], course:, subject:)
      end
    end
    TeacherAssignment.insert_all teacher_assignments
  end
end

ended_on = Time.current
total_duration = (ended_on - started_on).in_milliseconds

logger.tagged("SUCCESS") do
  logger.info ("Finished in #{total_duration}ms")
  logger.info ("Subjects: #{Subject.count}")
  logger.info ("Teachers: #{Teacher.count}")
  logger.info ("Students: #{Student.count}")
  logger.info ("Courses: #{Course.count}")
  logger.info ("Exams: #{Exam.count}")
  logger.info ("Grades: #{Grade.count}")
end
