# frozen_string_literal: true

RAILS_VERSIONS = %w[
  8.0.0
  8.1.0
]

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'activemodel', "~> #{version}"
    gem 'activerecord', "~> #{version}"

    gem 'sqlite3', '~> 2.2', platforms: [:ruby, :rbx]

    if !ENV['CI'] || %w(postgres postgresql).include?(ENV['DB'])
      group :postgres, :postgresql do
        gem 'pg', '~> 1.1', platforms: [:ruby, :rbx]
      end
    end

    platforms :jruby do
      if !ENV['CI'] || ENV['DB'] == 'sqlite3'
        gem 'activerecord-jdbcsqlite3-adapter', '~> 1'
      end

      if !ENV['CI'] || ENV['DB'] == 'mysql'
        gem 'activerecord-jdbcmysql-adapter', '~> 1'
      end

      if !ENV['CI'] || %w(postgres postgresql).include?(ENV['DB'])
        gem 'activerecord-jdbcpostgresql-adapter', '~> 1'
      end
    end
  end
end
