class Tezos::VotingPeriod < ApplicationRecord
  belongs_to :chain
  has_many :ballots

  def quorum_reached?
    rolls_voted = self.ballots.sum { |b| b.rolls }
    return rolls_voted >= self.quorum
  end

  def supermajority_reached?
    yay_rolls = self.ballots.where(vote: "yay").sum { |b| b.rolls }
    return (yay_rolls.to_f / self.total_rolls.to_f) >= 0.80
  end

end
