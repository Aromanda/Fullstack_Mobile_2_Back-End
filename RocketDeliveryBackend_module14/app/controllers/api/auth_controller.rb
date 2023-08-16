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
      # TODO
    end

    # POST /api/account/:id
    # Currently only covers customer and courier types
    def update_account
      # TODO
    end

  end
end
