module AuthToken
  extend ActiveSupport::Concern

  class_methods do
    # Find a user by JWT token
    #
    # @param token [String] the JWT token
    # @return [User, nil] the user if found, nil otherwise
    def find_by_jwt(token)
      payload, = JWT.decode(token, Rails.application.secrets.secret_key_base)
      return unless payload
      return unless payload.key?('sub')
      return if payload['exp'] < Time.now.to_i
      find_by(id: payload['sub'])
    rescue => e
      Rails.logger.error "Failed to decode JWT: #{e.message}"
    end
  end

  included do
    # Gets a JWT token for the user
    #
    # @return [String] the JWT token
    def jwt
      # Generate a JWT token for the user
      payload = { id: id, exp: 24.hours.from_now.to_i }
      JWT.encode(payload, Rails.application.secrets.secret_key_base)
    end
  end
end