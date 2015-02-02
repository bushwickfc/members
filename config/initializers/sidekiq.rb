require 'uri'
require 'redis'

SIDEKIQ_REDIS_NAMESPACE = Rails.application.class.parent.to_s

if ENV['RACK_ENV'] == 'production' || ENV['RACK_ENV'] == 'staging'
  redis_url = URI.parse(ENV["REDIS_URL"]=ENV['REDISTOGO_URL'])
  redis_config = { host: redis_url.host, port: redis_url.port,
                   password: redis_url.password }
else
  ENV['REDIS_PROVIDER']='REDIS_URL'
  ENV['REDIS_URL']||='redis://localhost:6379/0'
  redis_url = URI.parse(ENV["REDIS_URL"])
  redis_config = { host: redis_url.host, port: redis_url.port}
end
redis_url = redis_url.to_s

Sidekiq.configure_server do |config|
  config.redis = { namespace: SIDEKIQ_REDIS_NAMESPACE }
end

Sidekiq.configure_client do |config|
  config.redis = { namespace: SIDEKIQ_REDIS_NAMESPACE }
end

if ENV['SIDEKIQ_USER'] && ENV['SIDEKIQ_PASSWORD']
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_USER'] && password == ENV['SIDEKIQ_PASSWORD']
  end
end

redis = Redis.new(redis_config)
redis_ns = Redis::Namespace.new(SIDEKIQ_REDIS_NAMESPACE, redis: redis)
