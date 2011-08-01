# encoding: utf-8
module Globalize
  class Utils
    class << self
      def model_dir
        @model_dir || "app/models"
      end

      def model_dir=(dir)
        @model_dir = dir
      end
      
      def show_log(action, table_name, name=false, type=false)
        log = []
        log << action
        log << ' ' + table_name.to_s
        log << '.' + name.to_s if name
        log << ' as ' + type.to_s if type
        
        puts log.join
      end
    
      # Return a list of the model files to translate. If we have
      # command line arguments, they're assumed to be either
      # the underscore or CamelCase versions of model names.
      # Otherwise we take all the model files in the
      # model_dir directory.
      def get_model_files
        models = ARGV.dup
        models.shift
        models.reject!{|m| m.match(/^(.*)=/)}
        if models.empty?
          begin
            Dir.chdir(model_dir) do
              models = Dir["**/*.rb"]
            end
          rescue SystemCallError
            puts "No models found in directory '#{model_dir}'."
            exit 1;
          end
        end
        models
      end

      # Retrieve the classes belonging to the model names we're asked to process
      # Check for namespaced models in subdirectories as well as models
      # in subdirectories without namespacing.
      def get_model_class(file)
        require File.expand_path("#{model_dir}/#{file}") # this is for non-rails projects, which don't get Rails auto-require magic
        model = file.gsub(/\.rb$/, '').camelize
        parts = model.split('::')
        begin
          parts.inject(Object) {|klass, part| klass.const_get(part) }
        rescue LoadError, NameError
          Object.const_get(parts.last)
        end
      end
      
      # create or delete parent model fields, such as is_locale_{locale}
      def make_parent_checkers(klass, connect)
        columns = connect.columns(klass.table_name)
        
        Globalize.available_locales.each do |locale|
          name = "is_locale_#{locale}"
          
          unless columns.map(&:name).include?(name)
            connect.add_column klass.table_name, name, :boolean, :default => false
            show_log("add column", klass.table_name, name, :boolean)
          end
        end
      end
      
      def make_up(klass)
        conn = klass.connection
        table_name = klass.translations_table_name
        
        make_parent_checkers(klass, conn)
            
        if conn.table_exists?(table_name) # translated table exits
          columns = conn.columns(table_name)
          
          klass.translated_columns_hash.each do |key, value|
            columns.each do |column|
              if column.name.to_sym == key && column.type != value
                conn.change_column table_name, key, value
                show_log("change column", table_name, key, value)
              end
            end
            
            unless columns.map(&:name).include?(key.to_s)
              conn.add_column table_name, key, value
              show_log("add column", table_name, key, value)
            end
          end
          
          columns.each do |column|
            if !klass.translated_attribute_names.include?(column.name.to_sym) && [:string, :text].include?(column.type) && column.name != "locale"
              conn.remove_column table_name, column.name
              show_log("remove column", table_name, column.name)
            end
          end
        else
          klass.create_translation_table!(klass.translated_columns_hash)
          show_log("create table", table_name)
        end
      end
      
      def make_down(klass)
        if klass.connection.table_exists?(klass.translations_table_name)
          klass.drop_translation_table!
          show_log("drop table", klass.translations_table_name)
        end
      end

      def init(kind)
        get_model_files.each do |file|
          begin
            klass = get_model_class(file)
            if klass < ::ActiveRecord::Base && !klass.abstract_class? && klass.respond_to?(:translated_attribute_names)
              case kind
                when :up then make_up(klass)
                when :down then make_down(klass)
              end
            end
          rescue Exception => e
            puts "Unable to #{kind} #{file}: #{e.inspect}"
          end
        end
      end
      
      # Convert string "title:string" to hash { :title => :string }
      # Convert array ["title:string", "content:text"] to hash { :title => :string, :content => :text }
      def convert_columns(value)
        [value].flatten.inject({}) do |hash, schema|
          arr = schema.to_s.split(':')
          hash[arr.first.to_sym] = (arr.size == 1 ? :text : arr.last.to_sym)
          hash
        end
      end
    end
  end
end
