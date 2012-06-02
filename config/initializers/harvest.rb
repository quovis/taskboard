if HARVEST_CONFIG = YAML.load_file(Rails.root.join('config/harvest.yml'))[Rails.env].try(:with_indifferent_access)
  HARVEST_CLIENT = Harvest.hardy_client(
    HARVEST_CONFIG[:subdomain],
    HARVEST_CONFIG[:username],
    HARVEST_CONFIG[:password]
  )
end
