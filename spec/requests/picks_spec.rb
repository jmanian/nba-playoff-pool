require 'rails_helper'

RSpec.describe "Picks", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/picks/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/picks/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/picks/create"
      expect(response).to have_http_status(:success)
    end
  end

end
