require 'paper_trail'

module Globalize
  module Versioning
    module PaperTrail
      # At present this isn't used but we may use something similar in paper trail
      # shortly, so leaving it around to reference easily.
      #def versioned_columns
        #super + self.class.translated_attribute_names
      #end

      # Clear the `@globalize` instance method when `dup` is invoked to prevent inappropriate changes to the original copy
      def dup
        obj = super
        obj.tap { |o| o.send(:remove_instance_variable, :@globalize) } rescue obj
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  class << self
    def has_paper_trail_with_globalize(*args)
      has_paper_trail_without_globalize(*args)
      include Globalize::Versioning::PaperTrail
    end
    alias_method_chain :has_paper_trail, :globalize
  end
end

PaperTrail::Version.class_eval do

  before_save do |version|
    version.locale = Globalize.locale.to_s
  end

  def self.for_this_locale
    where :locale => Globalize.locale.to_s
  end

  def sibling_versions_with_locales
    sibling_versions_without_locales.for_this_locale
  end
  alias_method_chain :sibling_versions, :locales
end
