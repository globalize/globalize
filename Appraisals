# frozen_string_literal: true

RAILS_VERSIONS = %w[
  4.2.10
  5.1.6
  5.2.1
]

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'activemodel', version
    gem 'activerecord', version

    platforms :rbx do
      gem "rubysl", "~> 2.0"
      gem "rubinius-developer_tools"
    end

    platforms :jruby do
      if !ENV['TRAVIS'] || ENV['DB'] == 'sqlite3'
        gem 'activerecord-jdbcsqlite3-adapter', '~> 1'
      end

      if !ENV['TRAVIS'] || ENV['DB'] == 'mysql'
        gem 'activerecord-jdbcmysql-adapter', '~> 1'
      end

      if !ENV['TRAVIS'] || %w(postgres postgresql).include?(ENV['DB'])
        gem 'activerecord-jdbcpostgresql-adapter', '~> 1'
      end
    end
  end
end
