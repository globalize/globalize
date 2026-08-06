# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class SerializationLoadOrderTest < Minitest::Spec
  # Gems required before Globalize (audited, for example) register their own
  # `ActiveSupport.on_load(:active_record)` hooks first. Because hooks run in
  # registration order, such a gem can define a model -- and therefore call
  # `serialize` -- before Globalize's own hook has run, while Globalize's
  # `serialize` patch is already in place. This has to work regardless of that
  # ordering, so it is exercised in a subprocess where the hooks have not yet
  # been flushed.
  SCRIPT = <<~'RUBY'
    require 'active_record'

    ActiveSupport.on_load(:active_record) do
      Class.new(ActiveRecord::Base) do
        def self.name; 'Audited::Audit'; end
        self.table_name = 'audits'
        serialize :audited_changes
      end
    end

    require 'globalize'

    ActiveRecord::Base # flushes the hooks, in registration order
    puts 'ok'
  RUBY

  describe 'a model serialized from an earlier on_load hook' do
    it 'does not raise NameError for globalize_serialized_attributes' do
      lib = File.expand_path('../../../lib', __FILE__)
      output = IO.popen(['ruby', '-I', lib, '-e', SCRIPT], err: [:child, :out], &:read)

      assert_equal 'ok', output.strip
    end
  end
end
