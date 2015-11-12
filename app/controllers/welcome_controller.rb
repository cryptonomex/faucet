class WelcomeController < ApplicationController

    def index
        write_referral_cookie(params[:r]) if params[:r]
    end

    def error_404
        render status: 404, layout: false, template: 'welcome/error_404.html.erb'
    end

end
