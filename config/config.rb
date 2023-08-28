require "dotenv"
require "pathname"

class Config
  class << self
    attr_reader :root, :env, :secret_key

    def development? = env == "development"
    def production? = env == "production"
  end

  @root = Pathname("#{__dir__}/..").expand_path
  Dotenv.load(@root.join(".env"))
  @env = ENV['RACK_ENV'] ||= "development"
  @secret_key = ENV['SECRET_KEY']
end
