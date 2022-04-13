class AddStripeUserIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :stripe_user_id, :string
  end
end
