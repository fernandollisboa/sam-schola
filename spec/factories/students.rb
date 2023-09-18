# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    name { FFaker::Name.name }
    born_on { FFaker::Time.between(Date.current - 20.years, Date.current - 5.years).to_date }

    trait :enrolled_in_course do
      transient do
        year { Date.current.year }
      end

      after(:create) do |student, evaluator|
        course = create(:course, year: evaluator.year)
        create(:enrollment, student:, course:)
      end
    end
  end
end
