# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class ConnectionTest < Minitest::Spec
  describe 'translates' do
    it 'releases the connection take by the thread defining the model' do
      skip 'ActiveRecord < 7.2 always leases the connection' unless Globalize.rails_7_2?

      leased = Thread.new do
        Class.new(ActiveRecord::Base) do
          def self.name = 'ConnectionTestPost'
          translates :title
        end

        ActiveRecord::Base.connection_pool.active_connection?
      end.value

      refute leased
    end
  end
end
