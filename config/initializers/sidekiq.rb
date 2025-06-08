# redis_url = "redis://#{ Rails.application.credentials.redis[:username] }:#{ Rails.application.credentials.redis[:password] }@#{ Rails.application.credentials.redis[:host] }:#{ Rails.application.credentials.redis[:port] }/0" || ENV['REDIS_URL']
redis_url = ENV['REDIS_URL'] || "redis://#{ Rails.application.credentials.redis[:username] }:#{ Rails.application.credentials.redis[:password] }@#{ Rails.application.credentials.redis[:host] }:#{ Rails.application.credentials.redis[:port] }/0"
redis_timeout = 30

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
