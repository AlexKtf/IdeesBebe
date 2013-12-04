require 'spec_helper'

describe Profile do
  subject { user.profile }
  let(:user) { FactoryGirl.create :user }

  describe '#has_avatar?' do

    context 'with an avatar' do
      it 'returns true' do
        subject.build_avatar
        subject.save!
        subject.send(:has_avatar?).should == true
      end
    end

    context 'without an avatar' do
      it 'returns false' do
        subject.send(:has_avatar?).should == false
      end
    end
  end
end