# frozen_string_literal: true

RAILS_VERSIONS = %w[
  7.2.0
  8.0.0
  8.1.0
]

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'activemodel', "~> #{version}"
    gem 'activerecord', "~> #{version}"

    if Gem::Version.new(version) >= Gem::Version.new('8.0')
      gem 'sqlite3', '~> 2.2', platforms: [:ruby, :rbx]
    else
      gem 'sqlite3', '~> 1.4', platforms: [:ruby, :rbx]
    end

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
