# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

# Both need ActiveRecord::Base to not be loaded yet, hence subprocesses.
class SerializationLoadOrderTest < Minitest::Spec
  def run_script(script)
    lib = File.expand_path('../../../lib', __FILE__)
    IO.popen(['ruby', '-I', lib, '-e', script], err: [:child, :out], &:read).strip
  end

  # A gem required before globalize (audited) calls serialize from its own
  # on_load hook, which runs before ours (#843).
  EARLIER_HOOK_SCRIPT = <<~'RUBY'
    require 'active_record'

    ActiveSupport.on_load(:active_record) do
      Class.new(ActiveRecord::Base) do
        def self.name; 'Audited::Audit'; end
        self.table_name = 'audits'
        serialize :audited_changes
      end
    end

    require 'globalize'

    ActiveRecord::Base # runs the hooks
    puts 'ok'
  RUBY

  it 'does not raise when serialize is called from an earlier on_load hook' do
    assert_equal 'ok', run_script(EARLIER_HOOK_SCRIPT)
  end

  # Loading ActiveRecord::Base on require would run Rails' on_load hooks
  # (filter_parameters etc.) before the app's initializers.
  LAZY_LOAD_SCRIPT = <<~'RUBY'
    require 'active_record'

    loaded = false
    ActiveSupport.on_load(:active_record) { loaded = true }

    require 'globalize'

    puts loaded
  RUBY

  it 'does not load ActiveRecord::Base on require' do
    assert_equal 'false', run_script(LAZY_LOAD_SCRIPT)
  end
end
