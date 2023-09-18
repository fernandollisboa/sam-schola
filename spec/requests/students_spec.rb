# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/students' do
  let(:valid_attributes) do
    {
      name: 'Jon Snow',
      born_on: '1995-10-8'
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      born_on: '1995-10-8'
    }
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Student.create! valid_attributes
      get students_url
      expect(response).to be_successful
    end

    context 'when not provided optional param "year"' do
      let!(:students) { create_list(:student, 2, :enrolled_in_course) }
      let!(:student_enrolled_for_other_year) { create(:student, :enrolled_in_course, year: 2012) }

      it 'renders the students enrolled for the current year', aggregate_failures: true do
        get '/students'

        expect(response.body).to include(students[0].name)
        expect(response.body).to include(students[1].name)
      end

      it 'does not render the students enrolled for other years' do
        get '/students'

        expect(response.body).not_to include(student_enrolled_for_other_year.name)
      end
    end

    context 'when provided optional param "year"' do
      let(:year) { 2022 }
      let!(:students) { create_list(:student, 2, :enrolled_in_course, year:) }
      let!(:student_enrolled_for_other_year) { create(:student, :enrolled_in_course, year: year - 1) }

      it 'renders the students enrolled for the current year', aggregate_failures: true do
        get "/students?year=#{year}"

        expect(response.body).to include(students[0].name)
        expect(response.body).to include(students[1].name)
      end

      it 'does not render the students enrolled for other years' do
        get "/students?year=#{year}"

        expect(response.body).not_to include(student_enrolled_for_other_year.name)
      end
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      student = Student.create! valid_attributes
      get student_url(student)
      expect(response).to be_successful
    end

    context 'when the student is not enrolled for the current year' do
      let!(:student) { create(:student) }

      it 'renders an appropriate flash message' do
        get student_url(student)

        expect(flash[:notice]).to include("No Enrollment for the Current Year (#{Date.current.year})")
      end
    end

    context 'when not provided optional param "year"' do
      let(:year) { Date.current.year }
      let!(:student) { create(:student) }
      let!(:course) { create(:course, year:) }
      let!(:enrollment) { create(:enrollment, course:, student:) }
      let!(:subjects) { create_pair(:subject) }
      let!(:exams) { subjects.map { |subject| create(:exam, course:, subject:) } }
      let!(:grades) { exams.map { |exam| create(:grade, enrollment:, exam:) } }
      let!(:student_enrolled_for_other_year) { create(:student, :enrolled_in_course, year: year - 1) }
      let(:expected_subject_averages) do
        subjects.map do |subject|
          subject_exams = exams.find_all { |exam| exam.subject_id == subject.id }
          subject_grades = grades.select { |grade| subject_exams.pluck(:id).include? grade.exam_id }

          subject_grades.pluck(:value).sum.to_f / subject_grades.length
        end
      end

      it "renders the student's enrollment code for the current year" do
        get student_url(student)

        expect(response.body).to include(enrollment.code.to_s)
      end

      it "renders the student's course for the current year" do
        get student_url(student)

        expect(response.body).to include(course.name.to_s)
      end

      it "renders the student's average for each subject in the current year", aggregate_failures: true do
        get "/students/#{student.id}"

        expect(response.body).to include(subjects[0].name.to_s)
        expect(response.body).to include(subjects[1].name.to_s)
        expect(response.body).to include(expected_subject_averages[0].truncate(2).to_s)
        expect(response.body).to include(expected_subject_averages[1].truncate(2).to_s)
      end
    end

    context 'when provided optional param "year"' do
      let(:year) { 2012 }
      let!(:student) { create(:student) }
      let!(:course) { create(:course, year:) }
      let!(:enrollment) { create(:enrollment, course:, student:) }
      let!(:subjects) { create_pair(:subject) }
      let!(:exams) { subjects.map { |subject| create(:exam, course:, subject:) } }
      let!(:grades) { exams.map { |exam| create(:grade, enrollment:, exam:) } }
      let!(:student_enrolled_for_other_year) { create(:student, :enrolled_in_course, year: year - 1) }
      let(:expected_subject_averages) do
        subjects.map do |subject|
          subject_exams = exams.find_all { |exam| exam.subject_id == subject.id }
          subject_grades = grades.select { |grade| subject_exams.pluck(:id).include? grade.exam_id }

          subject_grades.pluck(:value).sum.to_f / subject_grades.length
        end
      end

      it "renders the student's enrollment code for the selected year" do
        get "/students/#{student.id}?year=#{year}"

        expect(response.body).to include(enrollment.code.to_s)
      end

      it "renders the student's course for the selected year" do
        get "/students/#{student.id}?year=#{year}"

        expect(response.body).to include(course.name.to_s)
      end

      it "renders the student's average for each subject in the selected year", aggregate_failures: true do
        get "/students/#{student.id}?year=#{year}"

        expect(response.body).to include(subjects[0].name.to_s)
        expect(response.body).to include(subjects[1].name.to_s)
        expect(response.body).to include(expected_subject_averages[0].truncate(2).to_s)
        expect(response.body).to include(expected_subject_averages[1].truncate(2).to_s)
      end
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_student_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      student = Student.create! valid_attributes
      get edit_student_url(student)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Student' do
        expect do
          post students_url, params: { student: valid_attributes }
        end.to change(Student, :count).by(1)
      end

      it 'redirects to the created student' do
        post students_url, params: { student: valid_attributes }
        expect(response).to redirect_to(student_url(Student.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Student' do
        expect do
          post students_url, params: { student: invalid_attributes }
        end.not_to change(Student, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post students_url, params: { student: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          name: 'Daenerys Targaryen',
          born_on: '1996-3-15'
        }
      end

      it 'updates the requested student' do
        student = Student.create! valid_attributes
        patch student_url(student), params: { student: new_attributes }
        student.reload
        expect(student.name).to eq('Daenerys Targaryen')
      end

      it 'redirects to the student' do
        student = Student.create! valid_attributes
        patch student_url(student), params: { student: new_attributes }
        student.reload
        expect(response).to redirect_to(student_url(student))
      end
    end

    context 'with invalid parameters' do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        student = Student.create! valid_attributes
        patch student_url(student), params: { student: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested student' do
      student = Student.create! valid_attributes
      expect do
        delete student_url(student)
      end.to change(Student, :count).by(-1)
    end

    it 'redirects to the students list' do
      student = Student.create! valid_attributes
      delete student_url(student)
      expect(response).to redirect_to(students_url)
    end
  end
end
