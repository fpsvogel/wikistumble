require_relative "config"
require "bundler"
Bundler.require(:default, Config.env)

# If race conditions arise, add the further code in
# https://github.com/janko/budget/blob/main/config/loader.rb
# and add this to config.ru:
#   use ReloadMiddleware if Config.development?
# For rationale, see https://github.com/fxn/zeitwerk#thread-safety
loader = Zeitwerk::Loader.new
loader.push_dir Config.root.join("app")
loader.collapse Config.root.join("app/*")
loader.enable_reloading if Config.development?
loader.setup
loader.eager_load if Config.production?
