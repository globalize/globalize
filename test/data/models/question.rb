class Question < ActiveRecord::Base
  translates :title, fallbacks_for_empty_translations: true, dependent: :delete_all
  validates :title, presence: true

  class Translation
    before_destroy { raise 'Cannot destroy question translations, only delete them' }
  end
end
