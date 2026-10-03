require "rails_helper"

RSpec.describe "Profiles", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, username: "old-name") }

  # Webpack assets aren't compiled in the test environment.
  before { allow(Webpacker.manifest).to receive(:lookup!).and_return("/stub") }

  describe "GET /profile/edit" do
    it "redirects when signed out" do
      get "/profile/edit"
      expect(response).to redirect_to(new_user_session_path)
    end

    it "renders when signed in" do
      sign_in user
      get "/profile/edit"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("old-name")
    end
  end

  describe "PATCH /profile" do
    before { sign_in user }

    it "updates the username without requiring a password" do
      patch "/profile", params: {user: {username: "new-name"}}
      expect(response).to redirect_to(edit_profile_path)
      expect(user.reload.username).to eq("new-name")
    end

    it "ignores attributes other than username" do
      patch "/profile", params: {user: {username: "new-name", email: "hacked@example.com", admin: true}}
      user.reload
      expect(user.email).not_to eq("hacked@example.com")
      expect(user.admin).to be(false)
    end

    it "re-renders with errors when the username is taken" do
      create(:user, username: "taken")
      patch "/profile", params: {user: {username: "taken"}}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(user.reload.username).to eq("old-name")
    end
  end
end
