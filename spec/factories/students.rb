# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    name { FFaker::Name.name }
    born_on { FFaker::Time.between(Date.current - 20.years, Date.current - 5.years).to_date }
  end
end
