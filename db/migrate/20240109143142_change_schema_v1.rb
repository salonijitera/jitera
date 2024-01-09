class ChangeSchemaV1 < ActiveRecord::Migration[6.0]
  def change
    create_table :users, comment: 'Stores user account information' do |t|
      t.boolean :email_verified

      t.string :verification_token

      t.string :password_hash

      t.string :password_reset_token

      t.string :email

      t.string :username

      t.timestamps null: false
    end
  end
end
