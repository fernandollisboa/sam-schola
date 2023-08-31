# frozen_string_literal: true

require 'logger'
logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
started_on = Time.current

last_ten_years = (11.years.ago.year..Date.current.year)

logger.tagged('STUDENTS') { logger.info 'Creating Students' }
students = FactoryBot.create_list :student, 10

logger.tagged('SUBJECTS') { logger.info 'Creating Subjects' }
subjects = FactoryBot.create_list :subject, 7

logger.tagged('TEACHERS') { logger.info 'Creating Teachers' }
teachers = FactoryBot.create_list :teacher, 25

def random_student_count_per_class
  rand(2..4)
end

def enroll_students(students_enrollments:, students_all:, year:, course:, students_count:)
  random_student_ids =  students_all.sample(students_count)

  random_student_ids.map do |student|
    if students_enrollments.key?(student.id)
     already_enrolled_for_the_year = students_enrollments[student.id] == year

      if already_enrolled_for_the_year
        student = FactoryBot.create(:student)
      end
    end

    enrollment = FactoryBot.create(:enrollment, course: course, student: student)
    students_enrollments[student.id] = year

    enrollment.code
  end
end

def create_enrollments(course_id:, students_ids:)
  enrollments = students_ids.map do |student_id|
    { code: SecureRandom.uuid, student_id:, course_id: }
  end
  Enrollment.insert_all enrollments
end

def create_grades(enrollment_codes:, course:, subject_id:, exams:, exams_per_student:)
  grades = []
  exams = exams.to_a

  exams.each do |exam|
    enrollment_codes.each do |enrollment_code|
      grades << { exam_id: exam['id'], enrollment_code:, value: rand(0.0..10.0) }
    end
  end

  Grade.insert_all grades
end

students_enrollments = {}
class_names = (5..6) # nth grade

last_ten_years.each do |year|
  class_names.each do |n|
    course = FactoryBot.create(:course, year:, name: "#{n}th grade")

    logger.tagged("YEAR=#{year}") { logger.info "Creating Classes for #{n}th grade" }

    teacher_assignments = []

    students_count = random_student_count_per_class
    course_enrollments = enroll_students(students_enrollments:, students_all: students, year:, course:, students_count:)

    teacher_subject_hash = teachers.sample(subjects.size).zip(subjects)
    teacher_subject_hash.each do |teacher, subject|

      teacher_assignments << { course_id: course.id, subject_id: subject.id, teacher_id: teacher.id}

      logger.tagged("YEAR=#{year}","#{n}th Grade") do
       logger.info "Creating classes for #{subject.name} with teacher #{teacher.name}"
      end


      quantity_of_exams = course.year == 2023 ? 1 : 2
      exam_realized_on = Date.new(course.year)

      exams = Array.new(quantity_of_exams * students_count) { FactoryBot.attributes_for(:exam, course_id: course.id, subject_id: subject.id, realized_on: exam_realized_on) }
      exams = Exam.insert_all(exams)

      create_grades(enrollment_codes: course_enrollments, course:, subject_id: subject.id, exams:, exams_per_student: quantity_of_exams)
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
  logger.info ("Enrollments: #{Enrollment.count}")
  logger.info ("Exams: #{Exam.count}")
  logger.info ("Grades: #{Grade.count}")
end
