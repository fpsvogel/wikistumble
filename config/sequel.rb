# DB = Sequel.connect(Config.db_url)
# # DB.logger = Logger.new($stdout) # RM unnecessary because of plugin :enhanced_logger
# DB.extension :pg_json, :null_dataset, :pagination

# Sequel::Model.cache_associations = false if Config.development?

# Sequel::Model.plugin :forme_set
# Sequel::Model.plugin :timestamps, update_on_create: true
# Sequel::Model.plugin :boolean_readers
