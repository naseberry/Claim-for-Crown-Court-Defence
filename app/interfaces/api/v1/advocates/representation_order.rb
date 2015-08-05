module API
  module V1

    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates

      class RepresentationOrder < Grape::API

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :representation_orders, desc: 'Create or Validate' do

          helpers do
            params :representation_order_creation do
              requires :defendant_id, type: String, desc: 'ID of the defendant'
              requires :granting_body, type: String, desc: "The court which granted this representation order (Crown Court or Magistrate's Court)"
              requires :maat_reference, type: String, desc: "The unique identifier for this representation order"
              requires :representation_order_date, type: Date, desc: "The date on which this representation order was granted (YYYY/MM/DD)"
            end

            def args
              {
                defendant_id: ::Defendant.find_by(uuid: params[:defendant_id]).try(:id),
                granting_body: params[:granting_body],
                maat_reference: params[:maat_reference],
                representation_order_date: params[:representation_order_date]
              }
            end

          end

          desc "Create a representation_order."

          params do
            use :representation_order_creation
          end

          post do
            representation_order = ::RepresentationOrder.create!(args)
            api_response = { 'id' => representation_order.reload.uuid }.merge!(declared(params))
            api_response
          end


          desc "Validate a representation_order."

          params do
            use :representation_order_creation
          end

          post '/validate' do
            representation_order = ::RepresentationOrder.new(args)

            if !representation_order.valid?
              error = ErrorResponse.new(representation_order)
              status error.status
              return error.body
            end

            status 200
            { valid: true }
          end
        end
      end
    end
  end
end
