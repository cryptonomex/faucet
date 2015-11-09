json.refcode do
  json.code @refcode.code
  json.expires_at @refcode.expires_at
  json.state @refcode.state
  json.account @refcode.funded_by
  json.asset_symbol @refcode.asset.symbol
  json.asset_amount @refcode.amount
end
