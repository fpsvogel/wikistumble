require_relative "config/config"
require "bundler"
Bundler.require(:default, Config.env)

# db = Sequel.connect(Config.db_url, test: false, keep_reference: false)

# namespace :db do
#   SequelTools.inject_rake_tasks({
#     dbadapter: db.opts[:adapter],
#     dbname: db.opts[:database],
#     dump_schema_on_migrate: Config.development?,
#     schema_location: "db/schema.sql",
#     log_level: :info,
#     sql_log_level: :info,
#   }, self)
# end

desc "Open a ruby console with the application loaded"
task :console => :boot do
  require "irb"
  ARGV.clear
  IRB.start
end

task :backup do
  system "pg_dump", db.opts[:database], out: "tmp/backup-#{Date.today.strftime("%Y%m%d")}.sql"
end

task :boot do
  require_relative "config/boot"
end
