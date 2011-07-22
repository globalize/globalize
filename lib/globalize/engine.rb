# encoding: utf-8
require 'rails'
require 'globalize'

module Globalize
  class Engine < ::Rails::Engine
    config.before_initialize do
      ActiveSupport.on_load :active_record do
        ::ActiveRecord::Base.extend(Globalize::ActiveRecord::ActMacro)
      end
    end
  end
end
