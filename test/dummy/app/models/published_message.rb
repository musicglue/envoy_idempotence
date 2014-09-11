class PublishedMessage < ActiveRecord::Base
  def self.unsent
    where(published_at: nil)
      .where('attempted_at IS NULL OR (attempted_at <= ?)', 1.minute.ago)
      .order(created_at: :asc)
  end

  validates :message, presence: true
  validates :topic, presence: true
end
