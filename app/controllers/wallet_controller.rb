class WalletController < ApplicationController
  #before_action :authenticate_user!

  def index
    render layout: false
  end

  def invoice_builder
    render layout: false
  end

end
