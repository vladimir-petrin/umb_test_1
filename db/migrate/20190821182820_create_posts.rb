class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.integer :user_id, null: false, index: true

      t.string :title, null: false
      t.text :content, null: false

      t.inet :author_ip, null: false, index: true
    end

    add_foreign_key :posts, :users
  end
end
