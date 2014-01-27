require 'spec_helper'

describe AttachmentsController do

  let (:user) { FactoryGirl.create(:user) }
  let (:entity) { FactoryGirl.create(:entity, user: user) }
  let (:transaction) { FactoryGirl.create(:transaction, entity: entity) }
  let (:attributes) do
    {
      raw_file: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'resources', 'attachment.png'), 'images/png')
    }
  end

  context 'for an authenticated user' do
    context 'to which the entity belongs' do
      before(:each) { sign_in user }

      describe "GET :index" do
        it 'should be successful' do
          get :index, transaction_id: transaction
          response.should be_success
        end

        context 'in json' do
          it 'should be successful' do
            get :index, transaction_id: transaction, format: :json
            response.should be_success
          end
        end
      end

      describe "GET :new" do
        it 'should be successful' do
          get :new, transaction_id: transaction
          response.should be_success
        end
      end

      describe "POST :create" do
        it 'should redirect to the attachment index page for the transaction' do
          post :create, transaction_id: transaction, attachment: attributes
          response.should redirect_to transaction_attachments_path(transaction)
        end

        it 'should create a new attachment record'
        context 'in json' do
          it 'should be successful'
          it 'should create a new attachment record'
        end
      end

      describe "GET :show" do
        it 'should be successful'
        context 'in json' do
          it 'should be successful'
        end
      end

      describe "DELETE :destroy" do
        it 'should redirect to the attachment index page for the transaction'
        it 'should remove the attachment from the system'
        context 'in json' do
          it 'should be successful'
          it 'should remove the attachment from the system'
        end
      end
    end

    context 'to which the entity does not belong' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }

      describe "GET :index" do
        it 'should redirect to the home page' do
          get :index, transaction_id: transaction
          response.should redirect_to home_path
        end

        context 'in json' do
          it "should return 'resource not found'" do
            get :index, transaction_id: transaction, format: :json
            response.response_code.should == 404
          end
        end
      end

      describe "GET :new" do
        it 'should redirect to the home page' do
          get :new, transaction_id: transaction
          response.should redirect_to home_path
        end
      end

      describe "POST :create" do
        it 'should redirect to the home page'
        it 'should not create a new attachment record'
        context 'in json' do
          it "should return 'resource not found'"
          it 'should not create a new attachment record'
        end
      end

      describe "GET :show" do
        it 'should redirect to the home page'
        context 'in json' do
          it "should return 'resource not found'"
        end
      end

      describe "DELETE :destroy" do
        it 'should redirect to the home page'
        it 'should note remove the attachment from the system'
        context 'in json' do
          it "should return 'resource not found'"
          it 'should not remove the attachment from the system'
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "GET :index" do
      it 'should redirect to the sign in page' do
        get :index, transaction_id: transaction
        response.should redirect_to new_user_session_path
      end

      context 'in json' do
        it "should return 'access denied'" do
          get :index, transaction_id: transaction, format: :json
          response.response_code.should == 401
        end
      end
    end

    describe "GET :new" do
      it 'should redirect to the sign in page' do
        get :new, transaction_id: transaction
        response.should redirect_to new_user_session_path
      end
    end

    describe "POST :create" do
      it 'should redirect to the sign in page'
      it 'should not create a new attachment record'
      context 'in json' do
        it "should return 'access deinied'"
        it 'should not create a new attachment record'
      end
    end

    describe "GET :show" do
      it 'should redirect to the sign in page'
      context 'in json' do
        it "should return 'access denied'"
      end
    end

    describe "DELETE :destroy" do
      it 'should redirect to the sign in page'
      it 'should not remove the attachment from the system'
      context 'in json' do
        it "should return 'access denied'"
        it 'should not remove the attachment from the system'
      end
    end
  end
end
