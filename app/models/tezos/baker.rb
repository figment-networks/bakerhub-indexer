class Tezos::Baker < ApplicationRecord
  belongs_to :chain, counter_cache: true
  has_many :blocks
  has_many :baking_rights, class_name: "Tezos::Block", inverse_of: :intended_baker
  has_many :missed_bakes
  has_many :ballots
  has_many :balance_change_events, class_name: "Tezos::Event::BalanceChange", inverse_of: :sender, foreign_key: :sender_id

  alias_attribute :address, :id

  def endorsing_stats_history
    fallback = { total_slots: 0, endorsed_slots: 0 }
    chain.cycles.order(id: :asc).pluck(Arel.sql("id, cached_endorsing_stats->'#{id}'")).to_h.transform_values! { |v| Tezos::EndorsingStats.new(**(v&.symbolize_keys || fallback)) }
  end

  def baking_stats_history
    fallback = { blocks_baked: 0, blocks_missed: 0, blocks_stolen: 0 }
    chain.cycles.order(id: :asc).pluck(Arel.sql("id, cached_baking_stats->'#{id}'")).to_h.transform_values! { |v| Tezos::BakingStats.new(**(v&.symbolize_keys || fallback)) }
  end

  def lifetime_endorsing_stats
    data = { total_slots: 0, endorsed_slots: 0 }
    endorsing_stats_history.each do |cycle, stats|
      data[:total_slots] += stats.total_slots
      data[:endorsed_slots] += stats.endorsed_slots
    end
    Tezos::EndorsingStats.new(data)
  end

  def lifetime_baking_stats
    data = { blocks_baked: 0, blocks_missed: 0, blocks_stolen: 0 }
    baking_stats_history.each do |cycle, stats|
      data[:blocks_baked] += stats.blocks_baked
      data[:blocks_missed] += stats.blocks_missed
      data[:blocks_stolen] += stats.blocks_stolen
    end
    Tezos::BakingStats.new(data)
  end

  def staking_balance(block: 'head')
    balance = Tezos::Rpc.get("blocks/#{block}/context/delegates/#{id}/staking_balance")
    balance.to_i
  rescue
    nil
  end
end
