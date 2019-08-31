class CreateAvgScores < ActiveRecord::Migration[6.0]
  def change
    create_table :avg_scores do |t|
      t.integer :post_id, null: false, index: { unique: true }

      t.integer :avg_value
    end

    add_foreign_key :avg_scores, :posts

    add_index :avg_scores, :avg_value, order: { avg_value: :desc }
  end
end
