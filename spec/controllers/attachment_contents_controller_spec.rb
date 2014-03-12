require 'spec_helper'

describe AttachmentContentsController do

  let (:attachment) { FactoryGirl.create(:attachment) }

  context 'for an authenticated user' do
    context 'to which the entity belongs' do
      before(:each) { sign_in attachment.transaction.entity.user }

      describe "GET 'show'" do
        it "should be successful" do
          get :show, id: attachment.attachment_content_id
          expect([200, 302]).to include(response.response_code)
        end
      end
    end

    context 'to which the entity does not belong' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }

      describe "GET 'show'" do
        it "should redirect to the home page" do
          get :show, id: attachment.attachment_content_id
          expect(response).to redirect_to home_path
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "GET 'show'" do
      it "should redirect to the sign in page" do
        get :show, id: attachment.attachment_content_id
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
