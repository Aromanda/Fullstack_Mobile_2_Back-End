module Api
  class AuthController < ActionController::Base
    skip_before_action :verify_authenticity_token
    include ApiHelper

    def index
      data = JSON.parse(request.body.read)
      email = data["email"]
      password = data["password"]
      user = User.find_by(email: email)
      customer = Customer.find_by(user_id: user&.id)
      courier = Courier.find_by(user_id: user&.id)

      if user && user.valid_password?(password)
        render json: { success: true, user_id: user.id, customer_id: customer&.id, courier_id: courier&.id }
      else
        render json: { success: false }, status: :unauthorized
      end
    end

    # GET /api/account/:id
    # Only covers customer and courier types for now
    def get_account
      user_id = params[:id]
      user_type = params[:type]
      user = User.find_by(id: user_id)
      puts "user_id", user_id
      puts "user_type", user_type
      puts "user", user

      if user.nil?
        render json: { error: "User not found" }, status: :not_found
        return
      end

      if user_type === "customer"
        customer = Customer.find_by(user_id: user.id)
        puts "customer", customer
        if customer.nil?
          render json: { error: "Customer not found" }, status: :not_found
          return
        end

        render json: {
          email: user.email,
          account_email: customer.email,
          account_phone: customer.phone
        }
      elsif user_type === "courier"
        puts "Im here"
        courier = Courier.find_by(user_id: user&.id)
        puts "courier", courier
        if courier.nil?
          render json: { error: "Courier not found" }, status: :not_found
          return
        end

        render json: {
          email: user.email,
          account_email: courier.email,
          account_phone: courier.phone
        }
      else
        render json: { error: "Invalid user type" }, status: :bad_request
      end
    end

    # POST /api/account/:id
    # Currently only covers customer and courier types
    def update_account
      user_id = params[:id]
      user_type = params[:type]
      data = JSON.parse(request.body.read)

      user = User.find_by(id: user_id)

      if user.nil?
        render json: { error: "User not found" }, status: :not_found
        return
      end

      if user_type === "customer"
        customer = Customer.find_by(user_id: user.id)
        if customer.nil?
          render json: { error: "Customer not found" }, status: :not_found
          return
        end

        # Update customer's email and phone
        customer.update(email: data["account_email"], phone: data["account_phone"])

        render json: {
          message: "Account information updated successfully",
          email: user.email,
          account_email: customer.email,
          account_phone: customer.phone
        }
      elsif user_type === "courier"
        courier = Courier.find_by(user_id: user&.id)
        if courier.nil?
          render json: { error: "Courier not found" }, status: :not_found
          return
        end

        # Update courier's email and phone
        courier.update(email: data["account_email"], phone: data["account_phone"])

        render json: {
          message: "Account information updated successfully",
          email: user.email,
          account_email: courier.email,
          account_phone: courier.phone
        }
      else
        render json: { error: "Invalid user type" }, status: :bad_request
      end
    end
  end
end
