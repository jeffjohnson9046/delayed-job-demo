class CreateMailings < ActiveRecord::Migration
  def change
    create_table :mailings do |t|
      t.string :subject
      t.string :body
      t.datetime :delivered_at

      t.timestamps
    end
  end
end
