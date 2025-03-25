require "rails_helper"

RSpec.describe User, type: :model do
  describe "#title" do
    subject { user.title }

    let(:user) { create :user }

    it { should eql user.email }
  end
end
