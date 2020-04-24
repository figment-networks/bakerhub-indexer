json.events @events, partial: "tezos/events/event", as: :event
json.cycle_number @tezos_cycle.number if @tezos_cycle
json.pagination @pagy
