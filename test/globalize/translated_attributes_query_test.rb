# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class TranslatedAttributesQueryTest < MiniTest::Spec
  def self.it_supports_translated_conditions(method)
    it 'finds records with matching attribute value in translations table' do
      post = Post.create(:title => 'title 1')
      Post.create(:title => 'title 2')
      assert_equal [post], Post.group(:id, :title).send(method, :title => 'title 1').load
    end

    it 'handles string-valued attributes' do
      post = Post.create(:title => 'title 1')
      Post.create(:title => 'title 2')
      assert_equal [post], Post.group(:id, :title).send(method, 'title' => 'title 1').load
    end

    it 'returns translations in this locale by default' do
      Globalize.with_locale(:ja) { Post.create(:title => 'タイトル') }
      assert Post.group(:id, :title).send(method, :title => 'タイトル').empty?
    end

    it 'returns chainable relation' do
      user = User.create(:email => 'foo@example.com', :name => 'foo')
      User.create(:email => 'bar@example.com', :name => 'foo')
      User.create(:email => 'foo@example.com', :name => 'baz')
      assert_equal [user], User.group(:id, :name, :email).send(method, :name => 'foo').send(method, :email => 'foo@example.com').load
    end

    it 'parses translated attributes in chained relations' do
      user = User.create(:email => 'foo@example.com', :name => 'foo')
      User.create(:email => 'bar@example.com', :name => 'foo')
      User.create(:email => 'foo@example.com', :name => 'baz')
      assert_equal [user], User.all.group(:id, :email, :name).send(method, :email => 'foo@example.com').send(method, :name => 'foo').load
    end

    it 'does not join translations table if query contains no translated attributes' do
      assert_equal User.group(:id, :email).send(method, :name => 'foo').joins_values, [:translations]
      assert_equal [], User.group(:id, :email).send(method, :email => 'foo@example.com').joins_values
    end

    it 'does not join translation table if already joined with with_translations' do
      user = Globalize.with_locale(:ja) { User.create(:email => 'foo@example.com', :name => 'foo') }
      assert_equal [user], User.with_translations('ja').group(:id, :name).send(method, :name => 'foo').to_a
    end

    it 'can be called with multiple arguments' do
      user = User.create(:email => 'foo@example.com', :name => 'foo')
      assert_equal user, User.group(:id, :email).send(method, "email = :email", { :email => 'foo@example.com' }).first
    end

    it 'duplicates arguments before modifying them' do
      User.group(:id, :name).send(method, args = { :name => 'foo' })
      assert_equal args, { :name => 'foo' }
    end
  end

  def self.it_supports_translated_order(method)
    describe 'returns record in order' do
      describe 'for translated columns' do
        it 'returns record in order, column as symbol' do
          @order = Post.where(:title => 'title').send(method, :title)

          case Globalize::Test::Database.driver
          when 'mysql'
            assert_match(/ORDER BY `post_translations`.`title` ASC/, @order.to_sql)
          else
            assert_match(/ORDER BY "post_translations"."title" ASC/, @order.to_sql)
          end
        end

        it 'returns record in order, column and direction as hash' do
          @order = Post.where(:title => 'title').send(method, title: :desc)

          case Globalize::Test::Database.driver
          when 'mysql'
            assert_match(/ORDER BY `post_translations`.`title` DESC/, @order.to_sql)
          else
            assert_match(/ORDER BY "post_translations"."title" DESC/, @order.to_sql)
          end
        end

        it 'returns record in order, columns in an array' do
          @order = Post.where(title: 'title').send(method, [:title, :content])

          case Globalize::Test::Database.driver
          when 'mysql'
            assert_match(/ORDER BY `post_translations`.`title` ASC/, @order.to_sql)
          else
            assert_match(/ORDER BY "post_translations"."title" ASC/, @order.to_sql)
          end
        end

        it 'returns record in order, leaving string untouched' do
          @order = Post.where(:title => 'title').send(method, 'title ASC')
          assert_equal ['title ASC'], @order.order_values
        end

        it 'generates a working query' do
          sql = Post.send(method, :title).to_sql
          assert Post.connection.execute(sql)
        end

        it 'returns relation that includes translated attribute' do
          @order = Post.send(method, :title)
          assert_equal [:translations], @order.joins_values
        end
      end

      describe 'for non-translated columns' do
        it 'returns record in order, column as symbol' do
          @order = Post.where(:title => 'title').send(method, :id)

          case Globalize::Test::Database.driver
          when 'mysql'
            assert_match(/ORDER BY `posts`.`id` ASC/, @order.to_sql)
          else
            assert_match(/ORDER BY "posts"."id" ASC/, @order.to_sql)
          end
        end

        it 'returns record in order, column and direction as hash' do
          @order = Post.where(:title => 'title').send(method, id: :desc)

          case Globalize::Test::Database.driver
          when 'mysql'
            assert_match(/ORDER BY `posts`.`id` DESC/, @order.to_sql)
          else
            assert_match(/ORDER BY "posts"."id" DESC/, @order.to_sql)
          end
        end

        it 'returns record in order, leaving string untouched' do
          @order = Post.where(:title => 'title').send(method, 'id ASC')
          assert_equal ['id ASC'], @order.order_values
        end

        it 'generates a working query' do
          sql = Post.send(method, :id).to_sql
          assert Post.connection.execute(sql)
        end

        it 'returns relation that does not include a translated attribute' do
          @order = Post.send(method, :id)
          assert_equal [], @order.joins_values
        end
      end

      describe 'for mixed columns' do
        it 'returns record in order, column and direction as hash' do
          @order = Post.where(:title => 'title').send(method, title: :desc, id: :asc)

          case Globalize::Test::Database.driver
          when 'mysql'
            assert_match(/ORDER BY `post_translations`.`title` DESC/, @order.to_sql)
            assert_match(/`id` ASC/, @order.to_sql)
          else
            assert_match(/ORDER BY "post_translations"."title" DESC/, @order.to_sql)
            assert_match(/"id" ASC/, @order.to_sql)
          end
        end

        it 'returns record in order, leaving string untouched' do
          @order = Post.where(:title => 'title').send(method, 'title ASC, id DESC')
          assert_equal ['title ASC, id DESC'], @order.order_values
        end

        it 'generates a working query' do
          sql = Post.send(method, :title, :id).to_sql
          assert Post.connection.execute(sql)
        end

        it 'returns relation that includes translated attribute' do
          @order = Post.send(method, :title, :id)
          assert_equal [:translations], @order.joins_values
        end
      end
    end
  end

  def self.it_supports_translated_columns(method)
    describe 'for translated columns' do
      it 'returns only selected attributes' do
        @rel = Post.send(method, :title)
        assert_match(/post_translations.title/, @rel.to_sql)
      end

      it 'generates a working query' do
        rel = Post.send(method, :title)
        rel = rel.select(:title) if method == :group
        assert Post.connection.execute(rel.to_sql)
      end

      it 'returns relation that includes translated attribute' do
        @rel = Post.send(method, :title)
        assert_equal [:translations], @rel.joins_values
      end
    end

    describe 'for non-translated columns' do
      it 'returns only selected attributes' do
        @rel = Post.send(method, :id)

        case Globalize::Test::Database.driver
        when 'mysql'
          assert_match(/`posts`.`id`/, @rel.to_sql)
        else
          assert_match(/"posts"."id"/, @rel.to_sql)
        end
      end

      it 'generates a working query' do
        sql = Post.send(method, :id).to_sql
        assert Post.connection.execute(sql)
      end

      it 'returns relation that does not include a translated attribute' do
        @rel = Post.send(method, :id)
        assert_equal [], @rel.joins_values
      end
    end

    describe 'for mixed columns' do
      it 'returns only selected attributes' do
        @rel = Post.send(method, :title, :id)

        case Globalize::Test::Database.driver
        when 'mysql'
          assert_match(/post_translations.title, `posts`.`id`/, @rel.to_sql)
        else
          assert_match(/post_translations.title, "posts"."id"/, @rel.to_sql)
        end
      end

      it 'generates a working query' do
        sql = Post.send(method, :title, :id).to_sql
        assert Post.connection.execute(sql)
      end

      it 'returns relation that includes translated attribute' do
        @rel = Post.send(method, :title, :id)
        assert_equal [:translations], @rel.joins_values
      end
    end
  end

  describe '.where' do
    it_supports_translated_conditions(:where)

    it 'can be called with no argument' do
      user = User.create(:email => 'foo@example.com', :name => 'foo')
      assert_equal [], User.where.not(:email => 'foo@example.com').load
      assert_equal [user], User.where.not(:email => 'bar@example.com').load
    end
  end

  describe '.having' do
    it_supports_translated_conditions(:having)
  end

  describe '.find_by' do
    it 'finds first record with matching attribute value in translations table' do
      Post.create(:title => 'title 1')
      post = Post.create(:title => 'title 2')
      assert_equal post, Post.find_by(:title => 'title 2')
    end

    it 'duplicates arguments before modifying them' do
      User.find_by(args = { :name => 'foo' })
      assert_equal args, { :name => 'foo' }
    end
  end

  describe '.find_or_create_by' do
    it 'returns first record with matching attribute value if one exists in translations table' do
      Post.create(:title => 'title 1')
      post = Post.create(:title => 'title 2')
      assert_equal post, Post.find_or_create_by(:title => 'title 2')
    end

    it 'creates record with translated attribute if no matching record exists' do
      post = Post.find_or_create_by(:title => 'title 1')
      post.reload
      assert_equal Post.first, post
      assert_equal post.title, 'title 1'
    end
  end

  describe '.not' do
    it 'finds records with attribute not matching condition in translations table' do
      Post.create(:title => 'title 1')
      post = Post.create(:title => 'title 2')
      assert_equal post, Post.where.not(:title => 'title 1').first
    end

    it 'does not join translations table if query contains no translated attributes' do
      assert_equal [:translations], User.where.not(:name => 'foo').joins_values
      assert_equal [], User.where.not(:email => 'foo@example.com').joins_values
    end

    it 'does not join translation table if already joined with with_translations' do
      user = Globalize.with_locale(:ja) { User.create(:email => 'foo@example.com', :name => 'bar') }
      assert_equal [user], User.with_translations('ja').where.not(:name => 'foo').to_a
    end

    it 'duplicates arguments before modifying them' do
      User.where.not(args = { :name => 'foo' })
      assert_equal args, { :name => 'foo' }
    end
  end

  describe '.exists?' do
    it 'returns true if record has attribute with matching value in translations table' do
      Post.create(:title => 'title 1')
      assert Post.exists?(:title => 'title 1')
      assert !Post.exists?(:title => 'title 2')
    end

    it 'duplicates arguments before modifying them' do
      User.exists?(args = { :name => 'foo' })
      assert_equal args, { :name => 'foo' }
    end
  end

  describe 'finder methods' do
    before do
      @posts = [
        Post.create(:title => 'title'),
        Post.create(:title => 'title'),
        Post.create(:title => 'title') ]
      Globalize.with_locale(:ja) do
        @posts[0].update_attributes(:title => 'タイトル1')
        @posts[1].update_attributes(:title => 'タイトル2')
        @posts[2].update_attributes(:title => 'タイトル3')
      end
    end

    it 'handles nil case' do
      assert_nil Post.where(:title => 'foo').first
      assert_nil Post.where(:title => 'foo').last
      assert_nil Post.where(:title => 'foo').take
    end

    describe '.first' do
      it 'returns record with all translations' do
        @first = Post.where(:title => 'title').first
        assert_equal @posts[0].translations.sort, @first.translations.sort
      end

      it 'accepts limit argument' do
        @first = Post.where(:title => 'title').first(2)
        assert_equal [@posts[0], @posts[1]], @first
      end
    end

    describe '.last' do
      it 'returns record with all translations' do
        @last = Post.where(:title => 'title').last
        assert_equal @posts[2].translations.sort, @last.translations.sort
      end

      it 'accepts limit argument' do
        @last = Post.where(:title => 'title').last(2)
        assert_equal [@posts[1], @posts[2]], @last
      end
    end

    describe '.take' do
      it 'returns record with all translations' do
        Globalize.with_locale(:ja) { @take = Post.where(:title => 'タイトル2').take }
        assert_equal @take.translations.sort, @posts[1].translations.sort
      end

      it 'accepts limit argument' do
        @take = Post.where(:title => 'title').take(2)
        assert_equal 2, @take.size
      end
    end
  end

  describe '.order' do
    it_supports_translated_order(:order)
  end

  describe '.reorder' do
    it_supports_translated_order(:reorder)
  end

  describe '.select' do
    it_supports_translated_columns(:select)
  end

  describe '.group' do
    it_supports_translated_columns(:group)
  end

  describe 'calculations' do
    before do
      @posts = [
        Post.create(:id => 1, :title => 'title1'),
        Post.create(:id => 2, :title => 'title2'),
        Post.create(:id => 3, :title => 'title3') ]
      Globalize.with_locale(:ja) do
        @posts[0].update_attributes(:title => 'タイトル1')
        @posts[1].update_attributes(:title => 'タイトル2')
        @posts[2].update_attributes(:title => 'タイトル3')
      end
    end

    describe '.pluck' do
      it 'plucks translated columns' do
        assert_equal ['title1', 'title2', 'title3'], Post.pluck(:title).sort
        Globalize.with_locale(:ja) do
          assert_equal ['タイトル1', 'タイトル2', 'タイトル3'], Post.pluck(:title).sort
        end
      end

      it 'plucks non-translated columns' do
        assert_equal [1, 2, 3], Post.pluck(:id).sort
        Globalize.with_locale(:ja) do
          assert_equal [1, 2, 3], Post.pluck(:id).sort
        end
      end

      it 'plucks mixed columns' do
        assert_equal [[1, 'title1'], [2, 'title2'], [3, 'title3']], Post.pluck(:id, :title).sort
        Globalize.with_locale(:ja) do
          assert_equal [[1, 'タイトル1'], [2, 'タイトル2'], [3, 'タイトル3']], Post.pluck(:id, :title).sort
        end
      end
    end

    describe '.calculate' do
      it 'calculates on translated column' do
        assert_equal 'title3', Post.calculate(:maximum, :title)
        Globalize.with_locale(:ja) do
          assert_equal 'タイトル3', Post.calculate(:maximum, :title)
        end
      end

      it 'calculates on non-translated column' do
        assert_equal 3, Post.calculate(:maximum, :id)
        Globalize.with_locale(:ja) do
          assert_equal 3, Post.calculate(:maximum, :id)
        end
      end
    end
  end

  describe '.where_values_hash' do
    it 'includes translated attributes' do
      # when translated attribute query passed in as attribute on association
      wheres = User.with_translations(:en).where(:email => 'foo@example.com', :user_translations => {'name' => 'test_name'}).where_values_hash
      assert_equal({ 'email' => 'foo@example.com', 'locale' => 'en', 'name' => 'test_name' }, wheres)

      # when translated attribute query passed in as attribute on parent model
      wheres = User.with_translations(:en).where(:email => 'foo@example.com', :name => 'test_name').where_values_hash
      assert_equal({ 'email' => 'foo@example.com', 'locale' => 'en', 'name' => 'test_name' }, wheres)
    end
  end

  describe 'fallbacks' do
    before(:each) do
      @previous_backend = I18n.backend
      I18n.pretend_fallbacks
      I18n.backend = BackendWithFallbacks.new

      I18n.locale = :en
      I18n.fallbacks = ::I18n::Locale::Fallbacks.new
      I18n.fallbacks.map('en' => [ 'ja' ])
    end

    after(:each) do
      I18n.fallbacks.clear
      I18n.hide_fallbacks
      I18n.backend = @previous_backend
    end

    it 'returns translations in fallback locales' do
      post = Post.create(:title => 'a title')
      Globalize.with_locale(:ja) { post.update_attributes :title => 'タイトル' }
      Globalize.with_locale(:fr) { post.update_attributes :title => 'titre' }

      # where
      assert_equal post, Post.where(:title => 'タイトル').first
      assert Post.where(:title => 'titre').empty?

      # find_by
      assert_equal post, Post.find_by(:title  => 'タイトル')
      assert_nil Post.find_by(:title => 'titre')

      # exists
      assert Post.exists?(:title => 'タイトル')
      assert !Post.exists?(:title => 'titre')
    end
  end

  describe 'associations' do
    it 'finds records with matching attribute value in translations table' do
      blog = Blog.create
      post = blog.posts.create(:title => 'a title')
      blog.posts.create(:title => 'another title')
      assert_equal [post], blog.posts.where(:title => 'a title').load

      comment = post.translated_comments.create(content: "something")
      post.translated_comments.create(content: "something else")
      assert_equal [comment], post.translated_comments.where(content: "something").load
      assert_equal [comment], blog.translated_comments.where(content: "something").load
    end

    it 'parses translated attributes in chained relations' do
      blog = Blog.create
      post = blog.posts.create(:title => 'a title', :content => 'foo')
      blog.posts.create(:title => 'a title', :content => 'bar')
      result = blog.posts.where(:content => 'foo').where(:title => 'a title').load
      assert_equal [post], result
    end

    it 'finds records that are not translated' do
      blog = Blog.create
      post = blog.posts.create(:title => 'a title')
      attachment = post.attachments.create(file_type: "image")
      assert_equal attachment, post.attachments.where(file_type: "image").first
      assert_equal attachment, blog.attachments.where(file_type: "image").first
    end

    it 'creates record from relation' do
      post = Post.create(:title => "title")
      post.translated_comments.where(content: "content").create
      assert_equal 1, Comment.count
    end
  end
end
