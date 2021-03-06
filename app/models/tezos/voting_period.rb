class Tezos::VotingPeriod < ApplicationRecord
  belongs_to :chain
  has_many :ballots

  validates :period_start_time, :period_type, presence: true

  def quorum_reached?
    rolls_voted = self.ballots.sum(&:rolls)
    return false if self.quorum.blank?

    percent_voted = (rolls_voted.to_f / self.total_rolls.to_f) * 10000
    percent_voted >= self.quorum
  end

  def supermajority_reached?
    yay_rolls = self.ballots.where(vote: "yay").sum { |b| b.rolls }
    total_rolls_voted = yay_rolls + self.ballots.where(vote: "nay").sum { |b| b.rolls }
    (yay_rolls.to_f / total_rolls_voted.to_f) >= 0.80
  end

  alias quorum_reached quorum_reached?
  alias supermajority_reached supermajority_reached?

  def end_time_approximation
    return nil if period_start_time.nil? || length_in_blocks.nil?
    period_start_time + length_in_blocks.minutes
  end

  def length_in_blocks
    return if end_position.nil? || start_position.nil?
    end_position - start_position
  end
end
