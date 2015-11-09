if Rails.env.production?
    Asset.create(objectid: '1.3.0', symbol: 'BTS', precision: 5)
else
    Asset.create(objectid: '1.3.0', symbol: 'CORE', precision: 5)
end
Asset.create(objectid: '1.3.105', symbol: 'SILVER', precision: 4)
Asset.create(objectid: '1.3.106', symbol: 'GOLD', precision: 6)
Asset.create(objectid: '1.3.113', symbol: 'CNY', precision: 4)
Asset.create(objectid: '1.3.120', symbol: 'EUR', precision: 4)
Asset.create(objectid: '1.3.121', symbol: 'USD', precision: 4)


Widget.create(user_id: 0, allowed_domains: Rails.application.config.faucet.default_url)