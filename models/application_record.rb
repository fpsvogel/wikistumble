require "active_record"

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
