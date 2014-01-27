require 'spec_helper'

describe AttachmentsController do

  let (:user) { FactoryGirl.create(:user) }
  let (:entity) { FactoryGirl.create(:entity, user: user) }
  let (:transaction) { FactoryGirl.create(:transaction, entity: entity) }
  let!(:attachment) { FactoryGirl.create(:attachment, transaction: transaction) }
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

        it 'should create a new attachment record' do
          expect do
            post :create, transaction_id: transaction, attachment: attributes
          end.to change(Attachment, :count).by(1)
        end

        context 'in json' do
          it 'should be successful' do
            post :create, transaction_id: transaction, attachment: attributes, format: :json
            expect(response).to be_success
          end

          it 'should create a new attachment record' do
            expect do
              post :create, transaction_id: transaction, attachment: attributes, format: :json
            end.to change(Attachment, :count).by(1)
          end
        end
      end

      describe "GET :show" do
        it 'should be successful' do
          get :show, id: attachment
          expect(response).to be_success
        end

        context 'in json' do
          it 'should be successful' do
            get :show, id: attachment, format: :json
            expect(response).to be_success
          end
        end
      end

      describe "DELETE :destroy" do
        it 'should redirect to the attachment index page for the transaction' do
          delete :destroy, id: attachment
          response.should redirect_to transaction_attachments_path(transaction)
        end

        it 'should remove the attachment from the system' do
          expect do
            delete :destroy, id: attachment
          end.to change(Attachment, :count).by(-1)
        end

        context 'in json' do
          it 'should be successful' do
            delete :destroy, id: attachment, format: :json
            expect(response).to be_success
          end

          it 'should remove the attachment from the system' do
            expect do
              delete :destroy, id: attachment, format: :json
            end.to change(Attachment, :count).by(-1)
          end
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
        it 'should redirect to the home page' do
          post :create, transaction_id: transaction, attachment: attributes
          expect(response).to redirect_to home_path
        end

        it 'should not create a new attachment record' do
          expect do
            post :create, transaction_id: transaction, attachment: attributes
          end.not_to change(Attachment, :count);
        end

        context 'in json' do
          it "should return 'resource not found'" do
            post :create, transaction_id: transaction, attachment: attributes, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'should not create a new attachment record' do
            expect do
              post :create, transaction_id: transaction, attachment: attributes, format: :json
            end.not_to change(Attachment, :count);
          end
        end
      end

      describe "GET :show" do
        it 'should redirect to the home page' do
          get :show, id: attachment
          expect(response).to redirect_to home_path
        end

        context 'in json' do
          it "should return 'resource not found'" do
            get :show, id: attachment, format: :json
            expect(response.response_code).to eq(404)
          end
        end
      end

      describe "DELETE :destroy" do
        it 'should redirect to the home page' do
          delete :destroy, id: attachment
          expect(response).to redirect_to home_path
        end

        it 'should note remove the attachment from the system' do
          expect do
            delete :destroy, id: attachment
          end.not_to change(Attachment, :count)
        end

        context 'in json' do
          it "should return 'resource not found'" do
            delete :destroy, id: attachment, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'should not remove the attachment from the system' do
            expect do
              delete :destroy, id: attachment, format: :json
            end.not_to change(Attachment, :count)
          end
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
      it 'should redirect to the sign in page' do
        post :create, transaction_id: transaction, attachment: attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'should not create a new attachment record' do
        expect do
          post :create, transaction_id: transaction, attachment: attributes
        end.not_to change(Attachment, :count)
      end

      context 'in json' do
        it "should return 'access denied'" do
          post :create, transaction_id: transaction, attachment: attributes, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'should not create a new attachment record' do
          expect do
            post :create, transaction_id: transaction, attachment: attributes, format: :json
          end.not_to change(Attachment, :count)
        end
      end
    end

    describe "GET :show" do
      it 'should redirect to the sign in page' do
        get :show, id: attachment
        expect(response).to redirect_to new_user_session_path
      end

      context 'in json' do
        it "should return 'access denied'" do
          get :show, id: attachment, format: :json
          expect(response.response_code).to eq(401)
        end
      end
    end

    describe "DELETE :destroy" do
      it 'should redirect to the sign in page' do
        delete :destroy, id: attachment
        expect(response).to redirect_to new_user_session_path
      end

      it 'should not remove the attachment from the system' do
        expect do
          delete :destroy, id: attachment
        end.not_to change(Attachment, :count)
      end

      context 'in json' do
        it "should return 'access denied'" do
          delete :destroy, id: attachment, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'should not remove the attachment from the system' do
          expect do
            delete :destroy, id: attachment, format: :json
          end.not_to change(Attachment, :count)
        end
      end
    end
  end
end
