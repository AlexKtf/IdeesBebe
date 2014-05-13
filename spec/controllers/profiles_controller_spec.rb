require 'spec_helper'

describe ProfilesController do
  subject { FactoryGirl.create :user }
  let(:user2) { FactoryGirl.create :user }

  before(:each) { sign_in subject }

  describe 'GET #show' do

    context 'visit my profile' do
      it 'return 200 with slug' do
        get :show, { id: subject.slug }
        expect(assigns(:user)).to eq(subject)
        expect(response.code).to eq('200')
      end
    end

    context 'visit other profile' do
      it 'return 200 with slug' do
        get :show, { id: user2.slug }
        expect(assigns(:user)).to eq(user2)
        expect(response.code).to eq('200')
      end
    end
  end


  describe 'GET #edit' do

    context 'edit my profile' do
      it 'return 200' do
        get :edit, { id: subject.slug }
        expect(assigns(:user)).to eq(subject)
        expect(response.code).to eq('200')
      end
    end

    context 'visit other profile' do
      it 'redirect if trying to edit somebody else profile' do
        get :edit, { id: user2.slug }
        expect(response).to redirect_to forbidden_path
      end
    end
  end

  describe 'PUT #update' do

    context 'update my profile' do

      it 'return 200 with success' do
        put :update, { id: subject.slug, profile: {'first_name' => 'test'} }
        expect(assigns(:user)).to eq(subject)
        expect(subject.reload.profile.first_name).to eq('test')
      end

      it 'return 200 with failed' do
        put :update, { id: subject.slug, profile: {'first_name' => '123'} }
        expect(assigns(:user)).to eq(subject)
        expect(subject.reload.profile.first_name).to eq(subject.profile.first_name)
      end

      context 'delete the avatar' do

        it 'success' do
          put :update, { id: subject.slug, profile: {'first_name' => 'test', 'avatar' => 'test' } }
          subject.reload.profile.avatar?.should == false
        end
      end
    end

    context 'update other profile' do
      it 'redirect if trying to update somebody else profile' do
        put :update, { id: user2.slug, profile: {'first_name' => 'test'} }
        expect(response).to redirect_to forbidden_path
        expect(user2.slug).to eq(user2.slug)
      end
    end
  end


  describe 'DELETE #destroy' do

    context 'destroy my profile' do
      it 'return 200' do
        delete :destroy, { id: subject.slug }
        User.exists?(subject.id).should == false
      end

      context 'with a failed destroy' do

        it 'flash an alert' do
          User.any_instance.stub(:destroy).and_return(false)
          delete :destroy, { id: subject.slug }
          flash[:alert].should_not be_nil
        end
      end
    end

    context 'destroy other profile' do
      it 'redirect if trying to destroy somebody else profile' do
        delete :destroy, { id: user2.slug }
        expect(response).to redirect_to forbidden_path
      end
    end
  end
end