class CreateUserViews < ActiveRecord::Migration[7.2]
  def change
    create_table :user_views, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.uuid :account_ids, array: true, default: [], null: false
      t.uuid :owner_ids,   array: true, default: [], null: false
      t.timestamps
    end
    add_index :user_views, [ :user_id, :name ], unique: true
  end
end
