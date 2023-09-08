# frozen_string_literal: true

class Query
  class << self
    def call(**args)
      new(**args).call
    end
  end
end
