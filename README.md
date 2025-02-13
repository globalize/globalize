![Globalize](http://globalize.github.io/globalize/images/globalize.png)

[![Build Status](https://github.com/globalize/globalize/workflows/CI/badge.svg)](https://github.com/globalize/globalize/actions) [![Code Climate](https://codeclimate.com/github/globalize/globalize.svg)](https://codeclimate.com/github/globalize/globalize)
[![Open Source Helpers](https://www.codetriage.com/globalize/globalize/badges/users.svg)](https://www.codetriage.com/globalize/globalize)

You can chat with us using Gitter:

[![Gitter chat](https://badges.gitter.im/globalize/globalize.svg)](https://gitter.im/globalize/globalize)

Globalize builds on the [I18n API in Ruby on Rails](http://guides.rubyonrails.org/i18n.html)
to add model translations to ActiveRecord models.

In other words, a way to translate actual user-generated content, for example; a single blog post with multiple translations.

## Current state of the gem

Globalize is not very actively maintained. Pull Requests are welcome, especially for compatibility with new versions of Rails, but none of the maintainers actively use Globalize anymore. If you need a more actively maintained model translation gem, we recommend checking out [Mobility](https://github.com/shioyama/mobility), a natural successor of Globalize created by Chris Salzberg (one of Globalize maintainers) and inspired by the ideas discussed around Globalize. For a more up-to-date discussion of the current situation, see [issue #753](https://github.com/globalize/globalize/issues/753).


## Requirements

* ActiveRecord >= 7.0 (see below for installation with older ActiveRecord)
* I18n

## Installation

To install the ActiveRecord 7.x compatible version of Globalize with its default setup, just use:

```ruby
gem install globalize
```

When using Bundler, put this in your Gemfile:

```ruby
gem "globalize", "~> 7.0"
```

Please help us by letting us know what works, and what doesn't, when using pre-release code. To use a pre-release, put this in your Gemfile:

```ruby
gem "globalize", git: "https://github.com/globalize/globalize", branch: "main"
```

## Older ActiveRecord
* Use Version 6.3 or lower

ActiveRecord 4.2 to 6.1:

```ruby
gem "globalize", "~> 6.3"
```

## Model translations

Model translations allow you to translate your models' attribute values. E.g.

```ruby
class Post < ActiveRecord::Base
  translates :title, :text
end
```

Allows you to translate the attributes :title and :text per locale:

```ruby
I18n.locale = :en
post.title # => Globalize rocks!

I18n.locale = :he
post.title # => גלובאלייז2 שולט!
```

You can also set translations with mass-assignment by specifying the locale:

```ruby
post.attributes = { title: "גלובאלייז2 שולט!", locale: :he }
```

In order to make this work, you'll need to add the appropriate translation tables.
Globalize comes with a handy helper method to help you do this.
It's called `create_translation_table!`. Here's an example:

Note that your migrations can use `create_translation_table!` and `drop_translation_table!`
only inside the `up` and `down` instance methods, respectively. You cannot use `create_translation_table!`
and `drop_translation_table!` inside the `change` instance method.

### Creating translation tables

Also note that before you can create a translation table, you have to define the translated attributes via `translates` in your model as shown above.

```ruby
class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Post.create_translation_table! :title => :string, :text => :text
      end

      dir.down do
        Post.drop_translation_table!
      end
    end
  end
end
```

Also, you can pass options for specific columns. Here’s an example:

```ruby
class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Post.create_translation_table! :title => :string,
          :text => {:type => :text, :null => false, :default => "abc"}
      end

      dir.down do
        Post.drop_translation_table!
      end
    end
  end
end
```

Note that the ActiveRecord model `Post` must already exist and have a `translates`
directive listing the translated fields.

## Migrating existing data to and from the translated version

As well as creating a translation table, you can also use `create_translation_table!`
to migrate across any existing data to the default locale. This can also operate
in reverse to restore any translations from the default locale back to the model
when you don't want to use a translation table anymore using `drop_translation_table!`

This feature makes use of `untranslated_attributes` which allows access to the
model's attributes as they were before the translation was applied. Here's an
example (which assumes you already have a model called `Post` and its table
exists):

```ruby
class TranslatePosts < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        Post.create_translation_table!({
          :title => :string,
          :text => :text
        }, {
          :migrate_data => true
        })
      end

      dir.down do
        Post.drop_translation_table! :migrate_data => true
      end
    end
  end
end
```

NOTE: Make sure you drop the translated columns from the parent table after all your data is safely migrated.

To automatically remove the translated columns from the parent table after the data migration, please use option `remove_source_columns`.

```ruby
class TranslatePosts < ActiveRecord::Migration
  def self.up
    Post.create_translation_table!({
      :title => :string,
      :text => :text
    }, {
      :migrate_data => true,
      :remove_source_columns => true
    })
  end

  def self.down
    Post.drop_translation_table! :migrate_data => true
  end
end
```


In order to use a specific locale for migrated data, you can use `I18n.with_locale`:

```ruby
    I18n.with_locale(:bo) do
      Post.create_translation_table!({
        :title => :string,
        :text => :text
      }, {
        :migrate_data => true
      })
    end
```

## Adding additional fields to the translation table

In order to add a new field to an existing translation table, you can use `add_translation_fields!`:

```ruby
class AddAuthorToPost < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        Post.add_translation_fields! author: :text
      end

      dir.down do
        remove_column :post_translations, :author
      end
    end
  end
end
```

NOTE: Remember to add the new field to the model:

```ruby
translates :title, :author
```
## Gotchas

Because globalize uses the `:locale` key to specify the locale during
mass-assignment, you should avoid having a `locale` attribute on the parent
model.

If you like your translated model to update if a translation changes, use the `touch: true` option together with `translates`:

```ruby
  translates :name, touch: true
```

## Known Issues

If you're getting the `ActiveRecord::StatementInvalid: PG::NotNullViolation: ERROR: null value in column "column_name" violates not-null constraint` error, the only known way to deal with it as of now is to remove not-null constraint for the globalized columns:

```ruby
class RemoveNullConstraintsFromResourceTranslations < ActiveRecord::Migration
  def change
    change_column_null :resource_translations, :column_name, true
  end
end
```

## Versioning with Globalize

See the [globalize-versioning](https://github.com/globalize/globalize-versioning) gem.

## I18n fallbacks for empty translations

It is possible to enable fallbacks for empty translations. It will depend on the
configuration setting you have set for I18n translations in your Rails config.

You can enable them by adding the next line to `config/application.rb` (or only
`config/environments/production.rb` if you only want them in production)

```ruby
# For version 1.1.0 and above of the `i18n` gem:
config.i18n.fallbacks = [I18n.default_locale]
# Below version 1.1.0 of the `i18n` gem:
config.i18n.fallbacks = true
```

By default, globalize will only use fallbacks when your translation model does
not exist or the translation value for the item you've requested is `nil`.
However it is possible to also use fallbacks for `blank` translations by adding
`:fallbacks_for_empty_translations => true` to the `translates` method.

```ruby
class Post < ActiveRecord::Base
  translates :title, :name
end

puts post.translations.inspect
# => [#<Post::Translation id: 1, post_id: 1, locale: "en", title: "Globalize rocks!", name: "Globalize">,
      #<Post::Translation id: 2, post_id: 1, locale: "nl", title: "", name: nil>]

I18n.locale = :en
post.title # => "Globalize rocks!"
post.name  # => "Globalize"

I18n.locale = :nl
post.title # => ""
post.name  # => "Globalize"
```

```ruby
class Post < ActiveRecord::Base
  translates :title, :name, :fallbacks_for_empty_translations => true
end

puts post.translations.inspect
# => [#<Post::Translation id: 1, post_id: 1, locale: "en", title: "Globalize rocks!", name: "Globalize">,
      #<Post::Translation id: 2, post_id: 1, locale: "nl", title: "", name: nil>]

I18n.locale = :en
post.title # => "Globalize rocks!"
post.name  # => "Globalize"

I18n.locale = :nl
post.title # => "Globalize rocks!"
post.name  # => "Globalize"
```

## Fallback locales to each other

It is possible to setup locales to fallback to each other.

```ruby
class Post < ActiveRecord::Base
  translates :title, :name
end

Globalize.fallbacks = {:en => [:en, :pl], :pl => [:pl, :en]}

I18n.locale = :en
en_post = Post.create(:title => "en_title")

I18n.locale = :pl
pl_post = Post.create(:title => "pl_title")
en_post.title # => "en_title"

I18n.locale = :en
en_post.title # => "en_title"
pl_post.title # => "pl_title"
```


## Scoping objects by those with translations

To only return objects that have a translation for the given locale we can use
the `with_translations` scope. This will only return records that have a
translations for the passed in locale.

```ruby
Post.with_translations("en")
# => [
  #<Post::Translation id: 1, post_id: 1, locale: "en", title: "Globalize rocks!", name: "Globalize">,
  #<Post::Translation id: 2, post_id: 1, locale: "nl", title: "", name: nil>
]

Post.with_translations(I18n.locale)
# => [
  #<Post::Translation id: 1, post_id: 1, locale: "en", title: "Globalize rocks!", name: "Globalize">,
  #<Post::Translation id: 2, post_id: 1, locale: "nl", title: "", name: nil>
]

Post.with_translations("de")
# => []
```

## Show different languages

In views, if there is content from different locales that you wish to display,
you should use the `with_locale` option with a block, as below:

```erb
<% Globalize.with_locale(:en) do %>
  <%= render "my_translated_partial" %>
<% end %>
```

Your partial will now be rendered with the `:en` locale set as the current locale.

## Interpolation

Globalize supports interpolation in a similar manner to I18n.

```ruby
class Post < ActiveRecord::Base
  translates :title
end

I18n.locale = :en
post.title = "Globalize %{superlative}!"

post.title
# #=> "Globalize %{superlative}!"

post.title(:foo => "bar")
# SomeError: missing interpolation argument :superlative

post.title(:superlative => "rocks")
# #=> "Globalize rocks!"
```

## Fragment caching

Don't forget to add globalize locale into the `cache_key` to separate different localizations of the record.
One of the possible ways to implement it:

```ruby
# inside translated model
def cache_key
  [super, Globalize.locale.to_s].join("-")
end
```

## Thread-safety

Globalize uses [request_store](https://github.com/steveklabnik/request_store) gem to clean up thread-global variable after every request.
RequestStore includes a Railtie that will configure everything properly.

If you're not using Rails, you may need to consult RequestStore's [README](https://github.com/steveklabnik/request_store#no-rails-no-problem) to configure it.

## Tutorials and articles
* [Go Global with Rails and I18n](http://www.sitepoint.com/go-global-rails-i18n/) - introductory article about i18n in Rails (Ilya Bodrov)

## Official Globalize extensions

* [globalize-accessors](https://github.com/globalize/globalize-accessors) - generator of accessor methods for models. *(e.g. title_en, title_cz)*
* [globalize-versioning](https://github.com/globalize/globalize-versioning) - versioning support for using Globalize with [`paper_trail`](https://github.com/airblade/paper_trail).

## Alternative solutions

* [Traco](https://github.com/barsoom/traco) - use multiple columns in the same model (Barsoom)
* [Mobility](https://github.com/shioyama/mobility) - pluggable translation framework supporting many strategies, including translatable columns, translation tables and hstore/jsonb (Chris Salzberg)
* [hstore_translate](https://github.com/cfabianski/hstore_translate) - use PostgreSQL's hstore datatype to store translations, instead of separate translation tables (Cédric Fabianski)
* [json_translate](https://github.com/cfabianski/json_translate) - use PostgreSQL's json/jsonb datatype to store translations, instead of separate translation tables (Cédric Fabianski)
* [Trasto](https://github.com/yabawock/trasto) - store translations directly in the model in a Postgres Hstore column

## Related solutions

* [friendly_id-globalize](https://github.com/norman/friendly_id-globalize) - lets you use Globalize to translate slugs (Norman Clarke)
