class PublishedMessage < ActiveRecord::Base
  def self.unsent
    where(published_at: nil)
      .where('attempted_at IS NULL OR (attempted_at <= ?)', 1.minute.ago)
      .order(created_at: :asc)
  end

  def self.sent_by publisher_id, timestamp
    where(published_by: publisher_id, attempted_at: timestamp)
  end

  validates :message, presence: true
  validates :topic, presence: true
end
