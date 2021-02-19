require "rails_helper"

describe Customer, type: :model do
  describe "relations" do
    it { should have_many :invoices }
    it { should have_many(:transactions).through(:invoices)}
  end
end