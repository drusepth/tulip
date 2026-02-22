# frozen_string_literal: true

# Rate limiting configuration for API endpoints
# Documentation: https://github.com/rack/rack-attack

class Rack::Attack
  ### Configure Cache ###
  # Use Rails cache for storing rate limit data
  Rack::Attack.cache.store = Rails.cache

  ### Throttle Spammy Clients ###
  # If any single client IP is making tons of requests, then they're probably misbehaving.
  # Block requests from IPs making more than 300 requests per 5 minutes.
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  ### Throttle API requests by user ###
  # Authenticated users get 100 requests per minute
  throttle("api/user", limit: 100, period: 1.minute) do |req|
    if req.path.start_with?("/api/v1/") && req.env["HTTP_AUTHORIZATION"].present?
      # Extract token from Authorization header
      token = req.env["HTTP_AUTHORIZATION"].to_s.split(" ").last
      # Use token as identifier (will be nil if not authenticated)
      token.presence
    end
  end

  ### Throttle Authentication Attempts ###
  # Prevent brute force attacks on login
  throttle("auth/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/tokens/sign_in" && req.post?
      req.ip
    end
  end

  # Prevent credential stuffing by limiting auth attempts per email
  throttle("auth/email", limit: 10, period: 1.minute) do |req|
    if req.path == "/users/tokens/sign_in" && req.post?
      # Normalize email to prevent case-based circumvention
      req.params.dig("email")&.downcase&.strip
    end
  end

  ### Exponential Backoff for Failed Auth ###
  # After 5 failed requests in 2 minutes, block for 5 minutes
  blocklist("fail2ban/auth") do |req|
    if req.path == "/users/tokens/sign_in" && req.post?
      # `filter` returns truthy value if request fails
      Rack::Attack::Fail2Ban.filter("fail2ban-#{req.ip}", maxretry: 5, findtime: 2.minutes, bantime: 5.minutes) do
        # Track only failed auth attempts (401 responses handled via observer)
        false
      end
    end
  end

  ### Custom Throttle Response ###
  self.throttled_responder = lambda do |request|
    now = Time.current
    match_data = request.env["rack.attack.match_data"]

    headers = {
      "Content-Type" => "application/json",
      "Retry-After" => (match_data[:period] - (now.to_i % match_data[:period])).to_s
    }

    body = {
      error: "Rate limit exceeded",
      retry_after: headers["Retry-After"].to_i
    }.to_json

    [ 429, headers, [ body ] ]
  end

  ### Safelist Requests ###
  # Allow localhost in development
  safelist("allow-localhost") do |req|
    "127.0.0.1" == req.ip || "::1" == req.ip
  end if Rails.env.development?
end

# Log throttled requests in production
ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _request_id, payload|
  Rails.logger.warn "[Rack::Attack] Throttled #{payload[:request].ip}: #{payload[:request].path}"
end
