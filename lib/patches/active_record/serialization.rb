# Gem load order is not guaranteed, so another gem's on_load(:active_record)
# hook can call `serialize` on a model before this one runs. Defining the
# attribute unconditionally here, rather than inside a hook, ensures it
# always exists before that happens.
ActiveRecord::Base.class_attribute :globalize_serialized_attributes, instance_writer: false
ActiveRecord::Base.globalize_serialized_attributes = {}

if ::ActiveRecord.version < Gem::Version.new("7.1.0")
  require_relative 'rails6_1/serialization'
elsif ::ActiveRecord.version < Gem::Version.new("7.2.0")
  require_relative 'rails7_1/serialization'
else
  require_relative 'rails7_2/serialization'
end
