require File.expand_path('../../test_helper', __FILE__)

class DirtyTrackingTest < Minitest::Spec

  describe '#changed' do
    it 'includes translated attributes in list of changed attribute keys' do
      post = Post.create(:title => 'title', :content => 'content')
      assert_equal [], post.changed

      post.title = 'changed title'
      assert_equal ['title'], post.changed

      post.content = 'changed content'
      assert_includes post.changed, 'title'
      assert_includes post.changed, 'content'
    end

    # ummm ... is this actually desired behaviour? probably depends on how we use it
    it 'lists attribute changed in other locale after locale switching' do
      post = Post.create(:title => 'title', :content => 'content')
      assert_equal [], post.changed

      post.title = 'changed title'
      I18n.locale = :de
      assert_equal ['title'], post.changed
    end

    it 'does not track fields with identical values' do
      post = Post.create(:title => 'title', :content => 'content')
      assert_equal [], post.changed

      post.title = 'title'
      assert_equal [], post.changed

      post.title = 'changed title'
      assert_equal({ 'title' => ['title', 'changed title'] }, post.changes)

      post.title = 'doubly changed title'
      assert_equal({ 'title' => ['title', 'doubly changed title'] }, post.changes)

      post.title = 'title'
      assert_equal [], post.changed
    end

    describe 'sti model' do
      it 'works with translated attributes in current locale' do
        child = Child.create(:content => 'foo')
        assert_equal [], child.changed

        child.content = 'bar'
        assert_equal ['content'], child.changed

        child.content = 'baz'
        assert_includes child.changed, 'content'
      end

      it 'works with translated attributes after locale switching' do
        child = Child.create(:content => 'foo')
        assert_equal [], child.changed

        child.content = 'bar'
        I18n.locale = :de

        assert_equal ['content'], child.changed
      end
    end
  end

  describe '#changes' do
    it 'tracks changes in each locale' do
      post = Post.create(:title => 'title', :content => 'content')
      assert_equal [], post.changed

      post.title = 'changed title'
      assert_equal({ 'title' => ['title', 'changed title'] }, post.changes)
      post.save

      I18n.locale = :de
      assert_nil post.title

      post.title = 'Titel'
      assert_equal({ 'title' => [nil, 'Titel'] }, post.changes)
    end

    it 'works for blank assignment' do
      post = Post.create(:title => 'title', :content => 'content')
      assert_equal [], post.changed

      post.title = ''
      assert_equal({ 'title' => ['title', ''] }, post.changes)
      post.save
    end

    it 'works for nil assignment' do
      post = Post.create(:title => 'title', :content => 'content')
      assert_equal [], post.changed

      post.title = nil
      assert_equal({ 'title' => ['title', nil] }, post.changes)
      post.save
    end

    it 'works for assigning new value == old value of other locale' do
      post = Post.create(:title => nil, :content => 'content')
      assert_equal ['content'], post.changed

      post.title = 'english title'

      if Globalize.rails_51?
        assert_equal ['title', 'content'], post.changed
      else
        assert_equal ['content', 'title'], post.changed
      end

      I18n.locale = :de
      post.title  = nil

      if Globalize.rails_51?
        assert_equal ['title', 'content'], post.changed
      else
        assert_equal ['content', 'title'], post.changed
      end
    end

    it 'works for restore changed state of other locale' do
      post = Post.create(:title => nil, :content => 'content')
      assert_equal ['content'], post.changed

      post.title = 'english title'
      if Globalize.rails_51?
        assert_equal ['title', 'content'], post.changed
      else
        assert_equal ['content', 'title'], post.changed
      end

      I18n.locale = :de
      post.title  = 'title de'

      if Globalize.rails_51?
        assert_equal ['title', 'content'], post.changed
      else
        assert_equal ['content', 'title'], post.changed
      end

      I18n.locale = :en
      post.title  = nil
      if Globalize.rails_51?
        assert_equal ['title', 'content'], post.changed
      else
        assert_equal ['content', 'title'], post.changed
      end

      I18n.locale = :de
      post.title  = nil
      assert_equal ['content'], post.changed
    end

    it 'only resets attributes once when nothing has changed' do
      post = Post.create(:title => 'title', :content => 'content')

      unless Globalize.rails_6?
        # Rails 6.0 and later has removed the attributes_changed_by_setter
        # hash so setting the key isn't necessary.
        post.send(:set_attribute_was, 'content', 'content')
      end

      post.content = 'content'
      assert post.save
    end
  end

  if Globalize.rails_51?
    describe '#saved_changes' do
      it 'tracks saved changes in each locale' do
        post = Post.create!(:title => 'title', :content => 'content')
        assert_equal({ 'id' => [nil, post.id], 'title' => [nil, 'title'], 'content' => [nil, 'content'] }, post.saved_changes)

        post.title = 'changed title'
        post.save
        assert_equal({ 'title' => ['title', 'changed title'] }, post.saved_changes)

        I18n.locale = :de
        assert_nil post.title

        post.title = 'Titel'
        post.save
        assert_equal({ 'title' => [nil, 'Titel'] }, post.saved_changes)
      end

      it 'clears saved changes after reload' do
        post = Post.create!(:title => 'title', :content => 'content')
        assert_equal({ 'id' => [nil, post.id], 'title' => [nil, 'title'], 'content' => [nil, 'content'] }, post.saved_changes)

        post.reload
        assert_equal({}, post.saved_changes)
      end
    end
  end
end
