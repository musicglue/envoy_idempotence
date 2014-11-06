class ProcessedMessage < ActiveRecord::Base
  validates :message_id, presence: true
  validates :queue, presence: true
  validates :message, presence: true

  def self.log message
    create!(
      message_id: message.id,
      queue: message.queue,
      message: message.to_h)
  end
end
