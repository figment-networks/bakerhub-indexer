class Tezos::Cycle < ApplicationRecord
  belongs_to :chain
  belongs_to :snapshot, class_name: "Tezos::Block", optional: true
  has_many :blocks
  has_many :endorsed_blocks
  has_many :bakers, through: :blocks
  has_many :missed_bakes, through: :blocks

  store_accessor :constants, :quorum_max,
                             :quorum_min,
                             :block_reward,
                             :nonce_length,
                             :cost_per_byte,
                             :tokens_per_roll,
                             :blocks_per_cycle,
                             :origination_size,
                             :preserved_cycles,
                             :initial_endorsers,
                             :endorsement_reward,
                             :endorsers_per_block,
                             :min_proposal_quorum,
                             :test_chain_duration,
                             :time_between_blocks,
                             :blocks_per_commitment,
                             :block_security_deposit,
                             :proof_of_work_threshold,
                             :blocks_per_roll_snapshot,
                             :blocks_per_voting_period,
                             :hard_gas_limit_per_block,
                             :proof_of_work_nonce_size,
                             :max_operation_data_length,
                             :max_revelations_per_block,
                             :seed_nonce_revelation_tip,
                             :max_proposals_per_delegate,
                             :michelson_maximum_type_size,
                             :endorsement_security_deposit,
                             :hard_gas_limit_per_operation,
                             :delay_per_missing_endorsement,
                             :hard_storage_limit_per_operation

  alias_attribute :number, :id
  alias_attribute :snapshot_height, :snapshot_id

  def needs_snapshot?
    snapshot_id.nil? && number >= 7
  end

  def snapshot_cycle_number
    [number - preserved_cycles - Tezos::Chain::SNAPSHOT_DELAY_CYCLES, 0].max
  end

  def start_height
    number * (blocks_per_cycle || 4096) + 1
  end

  def end_height
    start_height + (blocks_per_cycle || 4096) - 1
  end

  def start_time
    Tezos::Block.find_by(id: start_height)&.timestamp
  end

  def end_time
    Tezos::Block.find_by(id: end_height)&.timestamp || projected_end_time
  end

  def projected_end_time
    most_recent_block.timestamp + seconds_remaining.seconds
  end

  def seconds_remaining
    blocks_left * (time_between_blocks&.first || 60).to_i
  end

  def blocks_left
    blocks_per_cycle - blocks_count
  end

  def most_recent_block
    blocks.order(id: :asc).last
  end

  def missed_bakes_count
    # TODO: cache if we have all results
    return self[:missed_bakes_count] if self[:missed_bakes_count].present?
    blocks.sum(:baker_priority)
  end

  def cached_endorsing_stats
    return if self[:cached_endorsing_stats].nil?
    @cached_endorsing_stats ||= self[:cached_endorsing_stats].transform_values! { |v| Tezos::EndorsingStats.new(**v.symbolize_keys) }.with_indifferent_access
  end

  def cached_baking_stats
    return if self[:cached_baking_stats].nil?
    @cached_baking_stats ||= self[:cached_baking_stats].transform_values! { |v| v.is_a?(Integer) ? v : Tezos::BakingStats.new(**v.symbolize_keys) }.with_indifferent_access
  end

  def baking_stats
    data = { "missed_priorities" => missed_bakes_count }
    blocks.includes(:missed_bakes).find_each do |block|
      data[block.baker_id] ||= Tezos::BakingStats.new
      data[block.baker_id].blocks_baked += 1

      if block.stolen?
        data[block.baker_id].blocks_stolen += 1

        block.missed_bakes.each do |missed_bake|
          data[missed_bake.baker_id] ||= Tezos::BakingStats.new
          data[missed_bake.baker_id].blocks_missed += 1
        end
      end
    end
    data
  end

  def endorsing_stats
    data = { "total" => Tezos::EndorsingStats.new }
    endorsed_blocks.find_each do |block|
      block.by_slot.each do |slot, endorsed|
        data[block.endorsers[slot - 1]] ||= Tezos::EndorsingStats.new

        data[block.endorsers[slot - 1]].total_slots += 1
        data[block.endorsers[slot - 1]].endorsed_slots += 1 if endorsed

        data["total"].total_slots += 1
        data["total"].endorsed_slots += 1 if endorsed
      end
    end
    data
  end

  def get_constants_from_rpc
    if constants.nil?
      update_columns(constants: Tezos::Sync.new(chain).get_constants([start_height - 1, 1].max))
    end
  end
end
