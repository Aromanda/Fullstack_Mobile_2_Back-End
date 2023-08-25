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
      if user.nil?
        render json: { error: "User not found" }, status: :not_found
        return
      end

      case user_type
      when "customer"
        customer = Customer.find_by(user_id: user.id)
        if customer.nil?
          render json: { error: "Customer not found" }, status: :not_found
          return
        end

        render json: {
          email: user.email,
          customer_email: customer.email,
          customer_phone: customer.phone
        }
      when "courier"
        courier = Courier.find_by(user_id: user.id)
        if courier.nil?
          render json: { error: "Courier not found" }, status: :not_found
          return
        end

        render json: {
          email: user.email,
          courier_email: courier.email,
          courier_phone: courier.phone
        }
      else
        render json: { error: "Invalid user type" }, status: :bad_request
      end
    end

    # POST /api/account/:id
    # Currently only covers customer and courier types
    def update_account
      user_id = params[:id]
      user = User.find_by(id: user_id)

      if user.nil?
        render json: { error: "User not found" }, status: :not_found
        return
      end

      data = JSON.parse(request.body.read)

      if data.key?("customer_email") || data.key?("customer_phone")
        customer = Customer.find_by(user_id: user.id)
        if customer.nil?
          render json: { error: "Customer not found" }, status: :not_found
          return
        end

        customer.update(
          email: data["customer_email"] || customer.email,
          phone: data["customer_phone"] || customer.phone
        )
      elsif data.key?("courier_email") || data.key?("courier_phone")
        courier = Courier.find_by(user_id: user.id)
        if courier.nil?
          render json: { error: "Courier not found" }, status: :not_found
          return
        end

        courier.update(
          email: data["courier_email"] || courier.email,
          phone: data["courier_phone"] || courier.phone
        )
      else
        render json: { error: "Invalid update data" }, status: :bad_request
        return
      end

      render json: { success: true }
    end

  end
end
