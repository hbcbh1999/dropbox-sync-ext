class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :uuid
      t.string :dropbox_token
      t.timestamps
    end
  end
end
