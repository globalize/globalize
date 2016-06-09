require 'active_record'
require 'fileutils'
require 'logger'

module Globalize
  module Test
    module Database
      extend self

      DATABASE_PATH = File.expand_path('../database.yml', __FILE__)
      GLOBALIZE_LOG = File.expand_path('../../globalize_test.log', __FILE__)

      def connect
        version = ::ActiveRecord::VERSION::STRING
        driver  = Globalize::Test::Database.driver
        engine  = RUBY_ENGINE rescue 'ruby'

        FileUtils.touch(GLOBALIZE_LOG) unless File.exist?(GLOBALIZE_LOG)
        ::ActiveRecord::Base.logger = Logger.new(GLOBALIZE_LOG)
        ::ActiveRecord::LogSubscriber.attach_to(:active_record)

        ::ActiveRecord::Base.establish_connection config[driver]
        message = "Using #{engine} #{RUBY_VERSION} AR #{version} with #{driver}"

        puts "-" * 72
        if in_memory?
          ::ActiveRecord::Migration.verbose = false
          ::ActiveRecord::Schema.migrate :up
          puts "#{message} (in-memory)"
        else
          puts message
        end
      end

      def config
        @config ||= YAML::load(File.open(DATABASE_PATH))
      end

      def driver
        ENV.fetch('DB', 'sqlite3').downcase
      end

      def in_memory?
        config[driver]['database'] == ':memory:'
      end
    end
  end
end
