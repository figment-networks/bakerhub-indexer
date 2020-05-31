class Tezos::VotingPeriod < ApplicationRecord
  belongs_to :chain
  has_many :ballots

  def quorum_reached
    rolls_voted = self.ballots.sum { |b| b.rolls }
    percent_voted = (rolls_voted.to_f / self.total_rolls.to_f) * 10000
    puts percent_voted
    self.quorum.blank? ? false : (percent_voted >= self.quorum)
  end

  def supermajority_reached
    yay_rolls = self.ballots.where(vote: "yay").sum { |b| b.rolls }
    total_rolls_voted = yay_rolls + self.ballots.where(vote: "nay").sum { |b| b.rolls }
    (yay_rolls.to_f / total_rolls_voted.to_f) >= 0.80
  end

  def end_time_approximation
    self.period_start_time + 22.days + 18.hours
  end
end
