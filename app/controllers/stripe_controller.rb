class StripeController < ApplicationController
    require 'dotenv'
    Dotenv.load('.env')
    
    def connect
      response = HTTParty.post("https://connect.stripe.com/oauth/token",
        query: {
          client_secret: ENV["SECRET_KEY"],
          code: params[:code],
          grant_type: "authorization_code"
        }
      )
  
      if response.parsed_response.key?("error")
        redirect_to edit_user_registration_path,
          notice: response.parsed_response["error_description"]
      else
        stripe_user_id = response.parsed_response["stripe_user_id"]
        current_user.update_attribute(:stripe_user_id, stripe_user_id)
  
        redirect_to root_path,
          notice: 'User successfully connected with Stripe!'
      end
    end
    

    def create_checkout
        @user = current_user
        @product = Product.find(params[:product_id])
        @session = Stripe::Checkout::Session.create({
            line_items: [{
              price_data: {
                currency: 'usd',
                product_data: {
                  name: @product.title,
                },
                unit_amount: (@product.price * 100).to_i,
              },
              quantity: 1,
            }],
            payment_intent_data: {
              application_fee_amount: 123,
              transfer_data: {
                destination: @product.seller.stripe_user_id,
              },
            },
            mode: 'payment',
            success_url: checkout_success_url + '?session_id={CHECKOUT_SESSION_ID}',
            cancel_url: checkout_cancel_url,
          })

        redirect_to @session.url, status:303, allow_other_host: true
      end


    def success_checkout
        @session = Stripe::Checkout::Session.retrieve(params[:session_id])
        @payment_intent = Stripe::PaymentIntent.retrieve(@session.payment_intent)
    end

    def cancel_checkout
      puts params
        @session = Stripe::Checkout::Session.retrieve(params[:session_id])
        @payment_intent = Stripe::PaymentIntent.retrieve(@session.payment_intent)
    end

  end