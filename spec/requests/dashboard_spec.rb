require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /show" do
    pending "returns http success" do
      get "/dashboard/show"
      expect(response).to have_http_status(:success)
    end
  end

end
