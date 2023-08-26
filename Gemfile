source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "bridgetown", "~> 1.3.0"
gem "bridgetown-seo-tag", "~> 6.0"
gem "bridgetown-routes", "~> 1.3.0"
# Using only Sequel, but the AR plugin is required for now.
# See https://github.com/bridgetownrb/bridgetown-activerecord/pull/2
gem "bridgetown-activerecord", "~> 2.2"
gem "sequel-activerecord_connection", "~> 1.3"
gem "roda-turbo", "~> 1.0"

gem "puma", "< 7"
gem "pg", "~> 1.5"
gem "dotenv", "~> 2.8"

group :development do
  gem "annotate", "~> 3.2"
  gem "debug", "~> 1.8"
end

group :test, optional: true do
  gem "nokogiri"
  gem "minitest"
  gem "minitest-profile"
  gem "minitest-reporters"
  gem "shoulda"
  gem "rails-dom-testing"
end
