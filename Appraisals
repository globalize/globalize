# frozen_string_literal: true

RAILS_VERSIONS = %w[
  4.2.11.3
  5.1.7
  5.2.5
  6.0.3.6
  6.1.3.1
  7.0.1
]

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'activemodel', version
    gem 'activerecord', version
    
    if version =~ /^4/
      gem 'sqlite3', '~> 1.3.6', platforms: [:ruby, :rbx]
    elsif version =~ /^5/
      gem 'sqlite3', '~> 1.3', '>= 1.3.6', platforms: [:ruby, :rbx]
    else
      gem 'sqlite3', '~> 1.4', platforms: [:ruby, :rbx]
    end

    if !ENV['CI'] || %w(postgres postgresql).include?(ENV['DB'])
      group :postgres, :postgresql do
        if version =~ /^4/
          gem 'pg', '< 1.0', platforms: [:ruby, :rbx]
        else
          gem 'pg', '~> 1.1', platforms: [:ruby, :rbx]
        end
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
