class UserMailer < ApplicationMailer
    def refcode(email, refcode, note)
        subject = "#{refcode.asset_amount} #{refcode.asset.symbol} gift card (#{refcode.code})"
        vars = {
            'AMOUNT' => refcode.asset_amount,
            'SYMBOL' => refcode.asset.symbol,
            'CODE' => refcode.code,
            'CLAIM_LINK' => "#{Rails.application.config.faucet.links['wallet']}?refcode=#{refcode.code}",
            'NOTE' => note
        }
        body = mandrill_template('refcode', vars)
        send_mail(email, subject, body)
    end
end
