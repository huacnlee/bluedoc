nginx: /etc/nginx/start
sidekiq: bundle exec sidekiq -C config/sidekiq.yml
app: bundle exec puma -C config/puma-master.rb
caddy: caddy run --config /etc/Caddyfile