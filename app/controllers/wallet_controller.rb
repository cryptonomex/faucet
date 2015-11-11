require 'browser'

class WalletController < ApplicationController
    #before_action :authenticate_user!

    def index
        browser = Browser.new(ua: request.user_agent)
        @win_32 = browser.windows?
        render layout: false
    end

    def invoice_builder
        render layout: false
    end

end
