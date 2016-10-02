ActiveSupport::Deprecation.silence do
  class BadConfiguration < ActiveRecord::Base
    translates :name
  end
end
