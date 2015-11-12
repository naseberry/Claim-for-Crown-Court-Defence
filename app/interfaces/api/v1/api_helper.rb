module API
  module V1

    module ApiHelper

      require Rails.root.join('app', 'interfaces', 'api','custom_validations','date_format.rb')
      require_relative 'api_response'
      require_relative 'error_response'

      def self.authenticate_key!(params)
        chamber = Chamber.find_by(api_key: params[:api_key])
        if chamber.blank? || chamber.api_key.blank?
          raise API::V1::ArgumentError, 'Unauthorised'
        end
        chamber
      end

      def self.authenticate_claim!(params)
        chamber  = authenticate_key!(params)
        creator  = find_creator_by_email(params[:creator_email])
        advocate = find_advocate_by_email(params[:advocate_email])

        if creator.chamber != chamber || advocate.chamber != chamber
          raise API::V1::ArgumentError, 'Creator and advocate must belong to the chamber'
        end

        return { chamber: chamber, creator: creator, advocate: advocate }
      end

      def self.find_advocate_by_email(email)
        user = User.advocates.find_by(email: email)
        if user.blank?
          raise API::V1::ArgumentError, 'Advocate email is invalid'
        else
          @advocate = user.persona
        end
      end

      def self.find_creator_by_email(email)
        user = User.advocates.find_by(email: email)
        if user.blank?
          raise API::V1::ArgumentError, 'Creator email is invalid'
        else
          @advocate = user.persona
        end
      end

      def self.response_params(uuid, params)
        {'id' => uuid }.merge!(params.except(:api_key, :creator_email, :advocate_email))
      end

      # --------------------
      def self.create_resource(model_klass, params, api_response, arg_builder_proc)

        model_instance = validate_resource(model_klass, params, api_response, arg_builder_proc)

        if api_response.success?(200)
          created_or_updated_status = model_instance.new_record? ? 201 : 200
          model_instance.save!
          api_response.status = created_or_updated_status
          api_response.body = response_params(model_instance.reload.uuid, params)
        end

        model_instance

      # unexpected errors could be raised at point of save as well
      rescue Exception => ex
        err_resp = ErrorResponse.new(ex)
        api_response.status = err_resp.status
        api_response.body   = err_resp.body
      end

      # --------------------
      def self.validate_resource(model_klass, params, api_response, arg_builder_proc)

        authenticate_key!(params)

        #
        # basic fees (which are instantiated at claim creation)
        # must be updated if they already exist, otherwise created.
        # all other model class instances must be created.
        #

        args = arg_builder_proc.call
        if basic_fee_update_required(model_klass, args)
          model_instance = model_klass.where(fee_type_id: args[:fee_type_id], claim_id: args[:claim_id]).first
          model_instance.assign_attributes(args)
        else
          model_instance = model_klass.new(args)
        end

        if model_instance.valid?
          api_response.status = 200
          api_response.body =  { valid: true }
        else
          err_resp = ErrorResponse.new(model_instance)
          api_response.status = err_resp.status
          api_response.body   = err_resp.body
        end

        model_instance

      rescue Exception => ex
        err_resp = ErrorResponse.new(ex)
        api_response.status = err_resp.status
        api_response.body   = err_resp.body
      end

      # --------------------
      def self.basic_fee_update_required(model_klass, args)
        model_klass == ::Fee && (FeeType.find(args[:fee_type_id]).fee_category.is_basic? rescue false)
      end

    end
  end
end
