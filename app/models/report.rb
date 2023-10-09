# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  has_many :active_mentions, class_name: 'Mention', foreign_key: :mentioning_report_id, dependent: :destroy, inverse_of: :mentioning_report
  has_many :passive_mentions, class_name: 'Mention', foreign_key: :mentioned_report_id, dependent: :destroy, inverse_of: :mentioned_report

  has_many :mentioning_reports, through: :active_mentions, source: :mentioned_report
  has_many :mentioned_reports, through: :passive_mentions, source: :mentioning_report

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  def create_mentions
    ActiveRecord::Base.transaction do
      mentioned_ids = content.scan(%r{http://localhost:3000/reports/(\d+)}).flatten.uniq
      mentioned_ids.each do |mentioned_id|
        mention = active_mentions.new(mentioned_report_id: mentioned_id.to_i)
        mention.save!
      end
    end
  end
end
