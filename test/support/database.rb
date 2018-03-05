require 'active_record'
require 'fileutils'
require 'logger'
require 'yaml'

module Globalize
  module Test
    module Database
      extend self

      DATABASE_PATH = File.expand_path('../database.yml', __FILE__)
      GLOBALIZE_LOG = File.expand_path('../../globalize_test.log', __FILE__)
      DEFAULT_STRATEGY = :transaction

      def load_schema
        require File.expand_path('../../data/schema', __FILE__)
      end

      def connect
        version = ::ActiveRecord::VERSION::STRING
        driver  = Globalize::Test::Database.driver
        engine  = RUBY_ENGINE rescue 'ruby'

        FileUtils.touch(GLOBALIZE_LOG) unless File.exist?(GLOBALIZE_LOG)
        ::ActiveRecord::Base.logger = Logger.new(GLOBALIZE_LOG)
        ::ActiveRecord::LogSubscriber.attach_to(:active_record)

        ::ActiveRecord::Base.establish_connection config[driver]
        message = "Using #{engine} #{RUBY_VERSION} AR #{version} with #{driver}"

        puts '-' * 72
        if in_memory?
          ::ActiveRecord::Migration.verbose = false
          load_schema
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

      def create!
        db_config = config[driver]
        command = case driver
        when "mysql"
          "mysql -u #{db_config['username']} -e 'create database #{db_config['database']} character set utf8 collate utf8_general_ci;' >/dev/null"
        when "postgres", "postgresql"
          "psql -c 'create database #{db_config['database']};' -U #{db_config['username']} >/dev/null"
        end

        puts command
        puts '-' * 72
        %x{#{command || true}}
      end

      def drop!
        db_config = config[driver]
        command = case driver
        when "mysql"
          "mysql -u #{db_config['username']} -e 'drop database #{db_config["database"]};' >/dev/null"
        when "postgres", "postgresql"
          "psql -c 'drop database #{db_config['database']};' -U #{db_config['username']} >/dev/null"
        end

        puts command
        puts '-' * 72
        %x{#{command || true}}
      end

      def migrate!
        return if in_memory?
        ::ActiveRecord::Migration.verbose = true
        connect
        load_schema
        ::ActiveRecord::Schema.migrate :up
      end

      def mysql?
        driver == 'mysql'
      end

      def postgres?
        driver == 'postgres'
      end

      def sqlite?
        driver == 'sqlite3'
      end

      def native_array_support?
        postgres?
      end

      # PostgreSQL and MySql doen't support table names longer than 63 chars
      def long_table_name_support?
        sqlite?
      end

      def cleaning_strategy(strategy, &block)
        DatabaseCleaner.clean
        DatabaseCleaner.strategy = strategy
        DatabaseCleaner.cleaning(&block)
        DatabaseCleaner.strategy = DEFAULT_STRATEGY
      end
    end
  end
end
