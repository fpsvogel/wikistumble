Bridgetown.configure do |config|
  # For more documentation on how to configure your site using this initializers file,
  # visit: https://edge.bridgetownrb.com/docs/configuration/initializers/
  #
  # You can configure aspects of your Bridgetown site here instead of using
  # `bridgetown.config.yml`. For example:
  #
  # permalink "simple"
  # timezone "America/Los_Angeles"
  #
  # You can also modify options on the configuration object directly, like so:
  #
  # config.autoload_paths << "models"
  #

  # The Dotenv gem to load environment variables from `.env`
  init :dotenv

  # Bridgetown SSR (aka dynamic rendering of content via Roda):
  init :ssr

  # File-based dynamic template routing via Roda
  init :"bridgetown-routes"

  # We also recommend that if you're using Roda routes you include this plugin
  # so you can get a generated routes list in `.routes.json`. You can then run
  # `bin/bridgetown roda:routes` to print the routes. (This will require you to
  # comment your route blocks. See example in `server/routes/hello.rb.sample`.)
  only :server do
    init :parse_routes
  end

  # ActiveRecord and Sequel support
  config.autoload_paths << {
    path: "models",
    eager: true
  }

  config.autoloader_collapsed_paths << "models/concerns"
  init :"bridgetown-activerecord", sequel_support: :postgres
end
