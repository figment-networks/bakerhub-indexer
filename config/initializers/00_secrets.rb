creds = Rails.application.credentials

if !creds[Rails.env.to_sym]
  puts "Rails environment #{Rails.env} not defined in credentials.yml.enc! #{creds.inspect}"
  exit 1
end

SECRETS = JSON.parse creds[Rails.env.to_sym].merge(creds.shared || {}).to_json, object_class: OpenStruct

BakerhubIndexer::Application.config.secret_key_base = SECRETS.secret_key_base
