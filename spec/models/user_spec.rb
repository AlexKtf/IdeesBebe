# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  username               :string(255)
#  slug                   :string(255)
#  response_time          :integer          default(0)
#  provider               :string(255)
#  fb_id                  :string(255)
#  fb_tk                  :string(255)
#  is_admin               :boolean          default(FALSE)
#

require 'spec_helper'
require 'cancan/matchers'

describe User do
  subject { FactoryGirl.create :user }

  it_behaves_like Slugable do
    subject { FactoryGirl.create :user, username: "momé dad hOme" }
  end

  describe 'Abilities' do
    subject(:ability){ Ability.new(user) }
    let(:user) { FactoryGirl.create :user }
    let(:user2) { FactoryGirl.create :user }

    context 'with a guest user' do
      let(:user){ nil }

      context 'concerning a product' do

        it 'can :index on Product' do
          ability.should be_able_to(:index, Product.new)
        end

        it 'can :show on all the ressources' do
          ability.should be_able_to(:show, :all)
        end
      end

      context 'concerning a report' do
        let(:product2) { FactoryGirl.create :product, owner: user2 }

        it 'cannot create a report' do
          ability.should_not be_able_to(:create, Report.new(user: user, product: product2))
        end
      end
    end

    context 'with a connected user' do

      before(:each) { user.stub(:new_record?).and_return(false) }

      context 'concerning a user' do

        it 'can :destroy his account' do
          ability.should be_able_to(:destroy, user)
        end
      end

      context 'concerning an product asset' do
        let(:product) { FactoryGirl.create :product, owner: user }
        let(:product2) { FactoryGirl.create :product, owner: user2 }

        it 'can :destroy asset for his product' do
          ability.should be_able_to(:destroy, Photo.new(product: product))
        end

        it 'cannot :destroy asset from product of another' do
          ability.should_not be_able_to(:destroy, Photo.new(product: product2))
        end
      end

      context 'concerning a profile' do

        it 'can :manage his profile' do
          ability.should be_able_to(:manage, Profile.new(user: user))
        end

        it 'cannot :manage profile from another' do
          ability.should_not be_able_to(:manage, Profile.new(user: user2))
        end
      end

      context 'concerning a product' do

        it 'can :manage his product' do
          ability.should be_able_to(:manage, Product.new(owner: user))
        end

        it 'cannot :manage product from another' do
          ability.should_not be_able_to(:manage, Product.new(owner: user2))
        end
      end

      context 'concerning a message' do
        let(:product) { FactoryGirl.create :product, owner: user2 }
        let(:status) { FactoryGirl.create :status, product: product, user_id: user.id }

        it 'can :create message' do
          ability.should be_able_to(:create, Message.new(sender_id: user.id, receiver_id: user2.id, status: status, content: 'test'))
        end
      end

      context 'concerning a report' do

        context 'with a product from another' do
          let(:product2) { FactoryGirl.create :product, owner: user2 }

          it 'can create a report' do
            ability.should be_able_to(:create, Report.new(user_id: user.id, product: product2))
          end

          context 'when has already report the announce' do
            let(:report) { FactoryGirl.create :report, user: user, product: product2 }
            it 'cannot create a report' do
              report
              ability.should_not be_able_to(:create, Report.new(user_id: user.id, product: product2))
            end
          end
        end
      end
    end
  end

  describe 'when creates an user' do

    it 'create a profile' do
      expect {
        subject
      }.to change{Profile.count}.by 1
    end


    it 'sends a welcoming email' do
      subject
      Delayed::Worker.new.work_off
      deliveries_with_subject(I18n.t('notifier.welcome.subject')).count == 1
    end
  end

  describe '#is_owner_of?' do
    subject { FactoryGirl.create :user }
    let(:product) { FactoryGirl.create :product, owner: subject }

    context 'with one of his products' do
      
      it 'returns true' do
        subject.is_owner_of?(product).should == true
      end
    end

    context 'with products from other' do
      let(:user2) { FactoryGirl.create :user }
      let(:product) { FactoryGirl.create :product, owner: user2 }
      
      it 'returns false' do
        subject.is_owner_of?(product).should == false
      end
    end
  end

  describe '#satisfaction_rating' do

    it 'returns nil' do
      subject.satisfaction_rating.should == nil      
    end

    context 'with many products selled' do
      subject { FactoryGirl.create :user }
      let(:user) { FactoryGirl.create :user }
      let(:user2) { FactoryGirl.create :user }
      let(:user3) { FactoryGirl.create :user }
      let(:user4) { FactoryGirl.create :user }
      let(:product) { FactoryGirl.create :product, owner: subject }
      let(:product2) { FactoryGirl.create :product, owner: subject }
      let(:product3) { FactoryGirl.create :product, owner: subject }
      let(:product4) { FactoryGirl.create :product, owner: subject }
      let(:status) { FactoryGirl.create :status, user: user, product: product, satisfied: true }
      let(:status2) { FactoryGirl.create :status, user: user2, product: product2, satisfied: true }
      let(:status3) { FactoryGirl.create :status, user: user3, product: product3, satisfied: true }
      let(:status4) { FactoryGirl.create :status, user: user4, product: product4, satisfied: false }

      it 'returns the satisfaction rating' do
        status
        status2
        status3
        status4
        subject.satisfaction_rating.should == 75
      end
    end
  end
end
