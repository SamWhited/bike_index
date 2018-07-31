require "spec_helper"

RSpec.describe BikeCode, type: :model do
  describe "basic stuff" do
    let(:bike) { FactoryGirl.create(:bike) }
    let(:organization) { FactoryGirl.create(:organization, name: "Bike all night long", short_name: "bikenight") }
    let!(:spokecard) { FactoryGirl.create(:bike_code, kind: "spokecard", code: 12, bike: bike) }
    let!(:sticker) { FactoryGirl.create(:bike_code, code: 12, organization_id: organization.id) }
    it "calls the things we expect and finds the things we expect" do
      expect(BikeCode.claimed.count).to eq 1
      expect(BikeCode.unclaimed.count).to eq 1
      expect(BikeCode.spokecard.count).to eq 1
      expect(BikeCode.sticker.count).to eq 1
      expect(BikeCode.lookup("000012", organization_id: organization.id)).to eq sticker
      expect(BikeCode.lookup("000012", organization_id: organization.to_param)).to eq sticker
      expect(BikeCode.lookup("000012", organization_id: organization.short_name)).to eq sticker
      expect(BikeCode.lookup("000012", organization_id: organization.name)).to eq sticker
      expect(BikeCode.lookup("000012", organization_id: "whateves")).to eq spokecard
      expect(BikeCode.lookup("000012")).to eq spokecard
      expect(spokecard.claimed?).to be_truthy
    end
  end

  describe "can_be_linked_by?" do
    let(:user) { FactoryGirl.create(:user) }
    let(:organization) { FactoryGirl.create(:organization) }
    let(:membership) { FactoryGirl.create(:membership, user: user, organization: organization) }
    before { stub_const("BikeCode::MAX_UNORGANIZED", 1) }
    it "is truthy" do
      expect(BikeCode.new.linkable_by?(user)).to be_truthy
      # Already claimed bikes can't be linked
      expect(BikeCode.new(bike_id: 1243).linkable_by?(user)).to be_falsey
    end
    context "user has an unorganized bike_code" do
      let!(:bike_code) { FactoryGirl.create(:bike_code, user_id: user.id) }
      it "has expected values" do
        expect(BikeCode.new.linkable_by?(user)).to be_falsey
        expect(membership).to be_present
        user.reload
        expect(BikeCode.new.linkable_by?(user)).to be_falsey # Only has ability to link organized bike_codes
        expect(BikeCode.new(organization_id: organization.id).linkable_by?(user)).to be_truthy
        # Claimed can still be linked by a member of the org
        expect(BikeCode.new(organization_id: organization.id, bike_id: 1243).linkable_by?(user)).to be_truthy
        # Can't link other organization ones
        expect(BikeCode.new(organization_id: organization.id + 100).linkable_by?(user)).to be_falsey
        expect(BikeCode.new(bike_id: 1243).linkable_by?(user)).to be_falsey
      end
      context "user is superuser" do
        it "is always true" do
          user.superuser = true
          expect(BikeCode.new.linkable_by?(user)).to be_truthy
          expect(BikeCode.new(bike_id: 12).linkable_by?(user)).to be_truthy
        end
      end
    end
    context "user has an organized bike_code" do
      let!(:bike_code) { FactoryGirl.create(:bike_code, user_id: user.id, organization_id: organization.id) }
      it "has expected values" do
        expect(BikeCode.new.linkable_by?(user)).to be_falsey
        expect(membership).to be_present # Once user is part of the organization, they're permitted to link
        user.reload
        expect(BikeCode.new.linkable_by?(user)).to be_truthy
      end
    end
  end

  describe "claim" do
    let(:bike) { FactoryGirl.create(:bike) }
    let(:user) { FactoryGirl.create(:user) }
    let(:bike_code) { FactoryGirl.create(:bike_code) }
    it "claims, doesn't update when unable to parse" do
      bike_code.claim(user, bike.id)
      expect(bike_code.user).to eq user
      expect(bike_code.bike).to eq bike
      bike_code.claim(user, "https://bikeindex.org/bikes/9#{bike.id}")
      expect(bike_code.errors.full_messages).to be_present
      expect(bike_code.bike).to eq bike
      bike_code.claim(user, "https://bikeindex.org/bikes?per_page=200")
      expect(bike_code.errors.full_messages).to be_present
      expect(bike_code.bike).to eq bike
    end
    context "with weird strings" do
      it "updates" do
        bike_code.claim(user, "\nwww.bikeindex.org/bikes/#{bike.id}/edit")
        expect(bike_code.errors.full_messages).to_not be_present
        expect(bike_code.bike).to eq bike
        bike_code.claim(user, "\nwww.bikeindex.org/bikes/#{bike.id} ")
        expect(bike_code.errors.full_messages).to_not be_present
        expect(bike_code.bike).to eq bike
      end
    end
  end
end
