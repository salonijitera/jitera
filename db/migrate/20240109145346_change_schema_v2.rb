class ChangeSchemaV2 < ActiveRecord::Migration[6.0]
  def change
    create_table :password_reset_requests, comment: 'Tracks password reset requests and their statuses' do |t|
      t.string :token

      t.integer :status, default: 0

      t.datetime :expires_at

      t.timestamps null: false
    end

    add_column :users, :password_reset_expires_at, :datetime

    add_reference :password_reset_requests, :user, foreign_key: true
  end
end
