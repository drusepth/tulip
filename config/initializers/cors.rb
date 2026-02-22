# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow requests from mobile app and development environments
    origins(
      "localhost:3000",
      "127.0.0.1:3000",
      # Add your production domain here when deployed
      # "tulip.yourdomain.com",
      # Mobile apps don't need CORS (native HTTP), but Flutter web does
      "localhost:8080",
      "localhost:5000"
    )

    resource "/api/v1/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization" ],
      max_age: 86400

    # devise-api token endpoints
    resource "/users/tokens/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization" ],
      max_age: 86400
  end
end
