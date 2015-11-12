require 'browser'

class WalletController < ApplicationController
    #before_action :authenticate_user!

    def index
        browser = Browser.new(ua: request.user_agent)
        @platform = browser.windows? ? 'win32' : browser.platform
        render layout: false
    end

    def invoice_builder
        render layout: false
    end

end
