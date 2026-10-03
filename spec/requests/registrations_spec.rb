require "rails_helper"

RSpec.describe "Registrations", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, password: "old-password") }

  before do
    # Webpack assets aren't compiled in the test environment.
    allow(Webpacker.manifest).to receive(:lookup!).and_return("/stub")
    sign_in user
  end

  describe "PUT /users" do
    it "redirects to the profile page after updating" do
      put "/users", params: {user: {email: "new@example.com", current_password: "old-password"}}
      expect(response).to redirect_to(edit_profile_path)
      expect(user.reload.email).to eq("new@example.com")
    end

    it "requires the current password" do
      put "/users", params: {user: {email: "new@example.com"}}
      expect(user.reload.email).not_to eq("new@example.com")
    end
  end
end
