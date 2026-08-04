# `on_load(:active_record)` hooks run in registration order, so a gem
# required before Globalize (e.g. `audited`) can define a model -- and
# therefore call `serialize` -- from its own hook before any later Globalize
# hook runs, reaching the `serialize` patch below while
# `globalize_serialized_attributes` doesn't exist yet:
#
#   NameError: undefined local variable or method `globalize_serialized_attributes'
#
# Setting the attribute up here instead, unconditionally as this file loads,
# guarantees it always exists before the patch does, regardless of gem load
# order. `active_record` is already required by lib/globalize.rb by this
# point, so `ActiveRecord::Base` is available without needing `on_load` at all.
ActiveRecord::Base.class_attribute :globalize_serialized_attributes, instance_writer: false
ActiveRecord::Base.globalize_serialized_attributes = {}

if ::ActiveRecord.version < Gem::Version.new("7.1.0")
  require_relative 'rails6_1/serialization'
elsif ::ActiveRecord.version < Gem::Version.new("7.2.0")
  require_relative 'rails7_1/serialization'
else
  require_relative 'rails7_2/serialization'
end
