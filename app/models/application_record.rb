class ApplicationRecord < ActiveRecord::Base
  include UuidHelper
  self.abstract_class = true
end
