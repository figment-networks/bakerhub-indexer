json.extract! baker, :id, :name, :url

if params[:action] == "show"
  json.extract! baker, :lifetime_baking_stats,
                       :lifetime_endorsing_stats,
                       :baking_stats_history,
                       :endorsing_stats_history
end

json.url tezos_baker_url(baker, format: :json)
