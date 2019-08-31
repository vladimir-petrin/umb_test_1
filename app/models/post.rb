class Post < ApplicationRecord
  belongs_to :user

  has_many :scores, dependent: :destroy
  has_one :avg_score, dependent: :destroy

  def avg_score_value
    avg_score&.avg_value
  end
end
