json.extract! @tezos_baker, :id, :name, :url
json.staking_balance @tezos_baker.staking_balance(block: params[:block] || 'head')
