class Tezos::Proposal < ApplicationRecord
  belongs_to :chain
  has_many :ballots

  def status
    if self.is_promoted
        return "promoted"
    end

    data = Tezos::BlockData.retrieve(block_id: 'head', chain: chain)
    current_period = data.voting_period
    elapsed_periods = current_period - self.start_period

    if elapsed_periods >= 4
        return "rejected"
    elsif elapsed_periods == 3
        return self.passed_eval_period ? "promotion voting period" : "rejected"
    elsif elapsed_periods == 2
        return self.passed_eval_period ? "testing period" : "rejected"
    elsif elapsed_periods == 1
        return self.passed_prop_period ? "evaluation voting period" : "rejected"
    else
        return "proposal period"
    end
  end

end
