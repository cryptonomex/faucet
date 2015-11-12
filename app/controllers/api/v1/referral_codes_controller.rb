module Api
    module V1
        class ReferralCodesController < Api::BaseController

            def claim
                @refcode = ReferralCode.where(code: params[:referral_code_id]).first
                if @refcode
                    result = @refcode.claim(params[:account])
                    if result[:error]
                        render json: {error: result[:error]}, status: :unprocessable_entity
                        return
                    end
                    render action: 'show'
                else
                    render json: {error: 'referral code not found'}, status: :not_found
                end
            end

            def show
                render json: {}, status: :unauthorized
            end

            def create
                render json: {}, status: :unauthorized
            end

            def update
                render json: {}, status: :unauthorized
            end

            def destroy
                render json: {}, status: :unauthorized
            end

            private

            def resource_class
                ReferralCode
            end

            def resource_name
                'refcode'
            end

            def refcode_params
                params.require(:refcode).permit(:code, :account, :asset_symbol, :asset_amount, :send_to)
            end

            def query_params
                params.permit(:code)
            end

        end
    end
end
