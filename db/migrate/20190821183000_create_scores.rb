class CreateScores < ActiveRecord::Migration[6.0]
  def change
    create_table :scores do |t|
      t.integer :post_id, null: false, index: true

      t.integer :value, limit: 1, null: false
    end

    add_foreign_key :scores, :posts
  end
end
