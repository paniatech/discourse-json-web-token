# plugin.rb

enabled_site_setting :custom_token_auth_enabled

PLUGIN_NAME = 'discourse-json-web-token'.freeze

after_initialize do
  module ::DiscourseJsonWebToken
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseJsonWebToken
    end
  end

  class DiscourseJsonWebToken::AuthController < ApplicationController
    skip_before_action :redirect_to_login_if_required

    def login
      # Extract token from cookies
      token = cookies[:token]

      if token.present?
        # Validate token here (implement your own logic)
        if valid_token?(token)
          # Find or create user based on token data
          user_info = extract_user_info(token)
          user = find_or_create_user(user_info)

          # Log the user in
          log_on_user(user)

          # Redirect to homepage or wherever you want
          return redirect_to "/"
        end
      end

      # Handle invalid or expired token, or token not present
      redirect_to "/login"
    end

    private

    def valid_token?(token)
      # Implement your token validation logic here
      # This should return true if the token is valid, and false otherwise
      true # Placeholder, replace with actual validation logic
    end

    def extract_user_info(token)
      # Extract user information from the token
      # This should return a hash with user info, e.g. { username: ..., email: ..., etc. }
      { id: '123456789', name: 'erfan', username: 'erfan', email: 'erfan@example.com', password: '123456789' } # Placeholder, replace with actual extraction logic
    end

    def find_or_create_user(user_info)
      # Find or create a Discourse user based on the user info
      # This should return a user object
      User.find_or_create_by!(id: user_info[:id], name: user_info[:name], username: user_info[:username], email: user_info[:email], password: user_info[:password])
    end
  end

  Discourse::Application.routes.append do
    get "/auth/token_login" => "discourse_json_web_token/auth#login"
  end
end
