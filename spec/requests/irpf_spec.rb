require 'rails_helper'

RSpec.describe "Irpfs", type: :request do
  describe "GET /reports" do
    it "returns http success" do
      get "/irpf/reports"
      expect(response).to have_http_status(:success)
    end
  end

end
