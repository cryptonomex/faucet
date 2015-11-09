class WelcomeController < ApplicationController

    def index
        write_referral_cookie(params[:r]) if params[:r]
    end

end
