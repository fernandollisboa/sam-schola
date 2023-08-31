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
  end

  describe 'GET /show' do

    it 'renders a successful response' do
      student = Student.create! valid_attributes
      get student_url(student)
      expect(response).to be_successful
    end

    context 'when not passing optional params "year"' do
      let!(:student) { create(:student) }
      let!(:course) { create(:course, year: Date.current.year) }
      let!(:enrollment) { create(:enrollment, course:, student:) }
      let!(:exams) { create_pair(:exam, course:) }
      let!(:grades) { exams.map { |e| create(:grade, enrollment:, exam: e) } }

      it "renders the student's enrollment code for the current year" do
        get student_url(student)

        expect(response.body).to include("#{enrollment.code}")
      end

      it "renders the student's course for the current year" do
        get student_url(student)

        expect(response.body).to include("#{course.name}")
      end

      it "renders the student's grade point average for the current year" do
        get student_url(student)
        expected_gpa = grades.pluck(:value).sum.to_f / grades.size

        expect(response.body).to include("#{expected_gpa.truncate(2)}")
      end
    end

    context 'when passing optional params "year"' do
      let!(:student) { create(:student) }
      let!(:course) { create(:course, year:) }
      let!(:enrollment) { create(:enrollment, course:, student:) }
      let!(:exams) { create_pair(:exam, course:) }
      let!(:grades) { exams.map { |exam| create(:grade, enrollment:, exam:) } }
      let(:year) { 2012 }

      let!(:other_course) { create(:course, year: 2013)}
      let!(:other_enrollment) { create(:enrollment, course: other_course, student:) }
      let!(:other_exams) { create_pair(:exam, course: other_course) }
      let!(:other_grades) { other_exams.map { |exam| create(:grade, enrollment: other_enrollment, exam:, value: 0) } }

      it "renders the student's enrollment code for the selected year" do
        get "/students/#{student.id}?year=#{year}"

        expect(response.body).to include("#{enrollment.code}")
      end

      it "renders the student's course for the selected year" do
        get "/students/#{student.id}?year=#{year}"

        expect(response.body).to include("#{course.name}")
      end

      it "renders the student's grade point average for the selected year" do
        get "/students/#{student.id}?year=#{year}"
        expected_gpa = grades.pluck(:value).sum.to_f / grades.size

        expect(response.body).to include("#{expected_gpa.truncate(2)}")
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
