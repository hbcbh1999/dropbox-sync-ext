class CreateTextfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :textfiles do |t|
      t.belongs_to :user
      t.string :uuid
      t.string :textfile
      t.timestamps
    end
  end
end
