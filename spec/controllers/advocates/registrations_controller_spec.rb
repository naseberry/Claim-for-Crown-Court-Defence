require 'rails_helper'

RSpec.describe Advocates::RegistrationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST #create" do
    let(:email) { Faker::Internet.email }
    let(:sign_up_attributes) do
      {
        first_name: 'Bob',
        last_name: 'Smith',
        email: email,
        password: 'password1234',
        password_confirmation: 'password1234'
      }
    end

    context 'when env not api-sandbox' do
      before { post :create, user: sign_up_attributes, terms_and_conditions_acceptance: '1' }

      it 'redirects to user sign up path' do
        expect(response).to redirect_to(advocates_root_url)
      end

      it 'does not create a user' do
        expect(User.count).to eq(0)
      end

      it 'does not create an advocate' do
        expect(Advocate.count).to eq(0)
      end

      it 'does not create a chamber' do
        expect(Chamber.count).to eq(0)
      end
    end

    context 'when env api-sandbox' do
      before { ENV['ENV'] = 'api-sandbox' }

      context 'when valid' do
        context 'and terms and conditions are accepted' do
          before { post :create, user: sign_up_attributes, terms_and_conditions_acceptance: '1' }

          it 'creates a user' do
            expect(User.first.email).to eq(email)
          end

          it 'creates an advocate' do
            expect(User.first.persona).to be_a(Advocate)
          end

          it 'creates a chamber' do
            expect(User.first.persona.chamber).to_not eq(nil)
          end
        end

        context 'and terms and conditions are not accepted' do
          before { post :create, user: sign_up_attributes }

          it 'redirects to the sign up path' do
            expect(response).to redirect_to(new_user_registration_path)
          end

          it 'does not create a user' do
            expect(User.count).to eq(0)
          end

          it 'does not create an advocate' do
            expect(Advocate.count).to eq(0)
          end

          it 'does not create a chamber' do
            expect(Chamber.count).to eq(0)
          end
        end
      end

      context 'when invalid' do
        before do
          sign_up_attributes.delete(:email)
          post :create, user: sign_up_attributes
        end

        it 'does not create a user' do
          expect(User.count).to eq(0)
        end

        it 'does not create an advocate' do
          expect(Advocate.count).to eq(0)
        end

        it 'does not create a chamber' do
          expect(Chamber.count).to eq(0)
        end
      end
    end
  end
end
