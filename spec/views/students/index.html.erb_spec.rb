# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'students/index' do
  let(:students) { create_list(:student, 2) }

  before do
    student_attrs = students.map do |student|
      OpenStruct.new(**student.attributes, course_year: 2042, enrollment_code: 42, course_name: 42, persisted?: true)
    end

    assign(:students, student_attrs)
  end

  it 'renders a table of students' do
    render

    expect(rendered).to have_table(with_cols: [students.map(&:name)])
  end

  it 'renders actions links' do
    render

    expect(rendered).to have_selector('table tbody') do |table|
      expect(table).to have_selector('tr:nth-child(1) td:nth-child(5)') do |cell|
        expect(cell).to have_link('Show', href: student_path(students.first))
        expect(cell).to have_link('Edit', href: edit_student_path(students.first))
      end
      expect(table).to have_selector('tr:nth-child(2) td:nth-child(5)') do |cell|
        expect(cell).to have_link('Show', href: student_path(students.second))
        expect(cell).to have_link('Edit', href: edit_student_path(students.second))
      end
    end
  end
end
