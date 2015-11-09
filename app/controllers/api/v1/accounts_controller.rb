require 'thread'

module Api
    module V1
        class AccountsController < Api::BaseController

            def status
                @available = true
                account_name = params[:account_id]
                result, error = GrapheneCli.instance.exec('lookup_accounts', [account_name, 1])
                if error
                    logger.error("Error! Api.V1.AccountsController.status - lookup_accounts failed: #{error.inspect}")
                else
                    puts result.inspect
                    @available = !(result && result.length > 0 && result[0][0] == account_name)
                end
            end

            def show
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
                BtsAccount
            end

            def resource_name
                'account'
            end

            def account_params
                if params[:account]
                    params[:account][:remote_ip] = request.remote_ip
                    params[:account][:referrer] = cookies[:_referrer_] unless cookies[:_referrer_].blank?
                end
                params.require(:account).permit(:name, :owner_key, :active_key, :memo_key, :remote_ip, :refcode, :referrer)
            end

            def query_params
                params.permit(:name)
            end

        end
    end
end