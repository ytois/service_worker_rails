class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :endpoint, nul: false
      t.string :key
      t.string :auth
      t.timestamps null: false
    end
  end
end
