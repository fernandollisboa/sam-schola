# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subject do
  describe 'validations' do
    subject(:model) { build(:subject) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
