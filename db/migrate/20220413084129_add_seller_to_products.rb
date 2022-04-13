class AddSellerToProducts < ActiveRecord::Migration[7.0]
  def change
    add_reference :products, :seller, index: true
  end
end
