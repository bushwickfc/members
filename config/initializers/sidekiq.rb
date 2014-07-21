require 'uri'
require 'redis'

SIDEKIQ_REDIS_NAMESPACE = Rails.application.class.parent.to_s

if ENV['RACK_ENV'] == 'production' || ENV['RACK_ENV'] == 'staging'
  redis_url = URI.parse(ENV['REDISTOGO_URL'])
  redis_config = { host: redis_url.host, port: redis_url.port,
                   password: redis_url.password }
  redis_url = redis_url.to_s
else
  redis_url = 'redis://localhost:6379'
  redis_config = { host: 'localhost', port: 6379 }
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, namespace: SIDEKIQ_REDIS_NAMESPACE, size: 23 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, namespace: SIDEKIQ_REDIS_NAMESPACE, size: 10 }
end

if ENV['SIDEKIQ_USER'] && ENV['SIDEKIQ_PASSWORD']
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_USER'] && password == ENV['SIDEKIQ_PASSWORD']
  end
end

redis = Redis.new(redis_config)
redis_ns = Redis::Namespace.new(SIDEKIQ_REDIS_NAMESPACE, redis: redis)
