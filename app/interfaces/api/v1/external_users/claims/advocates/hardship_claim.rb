module API::V1::ExternalUsers
  module Claims
    module Advocates
      class HardshipClaim < Grape::API
        helpers API::V1::ClaimParamsHelper, API::V1::HardshipClaimParamsHelper

        params do
          def i18n_scope
            %i[api v1 external_users claims advocate_claim params]
          end

          def local_t(attribute)
            I18n.t(attribute.to_s, scope: i18n_scope)
          end
          use :agfs_hardship_params
          use :legacy_agfs_params
          optional :advocate_category,
                   type: String,
                   desc: local_t(:advocate_category),
                   values: (Settings.advocate_categories + Settings.agfs_reform_advocate_categories).uniq

          use :agfs_hardship_trial_params
          use :common_agfs_params
        end

        namespace :advocates do
          namespace :hardship do
            desc 'Create an Advocate hardship claim.'
            post do
              create_resource(::Claim::AdvocateHardshipClaim)
              status api_response.status
              api_response.body
            end

            desc 'Validate an Advocate hardship claim.'
            post '/validate' do
              validate_resource(::Claim::AdvocateHardshipClaim)
              status api_response.status
              api_response.body
            end
          end
        end
      end
    end
  end
end
