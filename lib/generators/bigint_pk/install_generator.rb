require 'rails/generators'

module BigintPk
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path '../templates', __FILE__
      DESTINATION_TYPE = "bigint(20)"
      desc 'Creates BigintPk initializer'

      def create_initializer_file
        template 'bigint_pk.rb', 'config/initializers/bigint_pk.rb'
      end

      def create_migration
        Rails.application.eager_load!

        tables = {}

        klasses = ActiveRecord::Base.descendants.select do |klass|
          ActiveRecord::Base.connection.table_exists?(klass.table_name)
        end

        klasses.each do |klass|
          options = {}

          belongs_to_associations = klass.reflect_on_all_associations.select do |association|
            (association.macro == :belongs_to) &&
              ActiveRecord::Base.connection.column_exists?(klass.table_name, association.foreign_key) &&
              (column = klass.columns_hash[association.foreign_key]) &&
              column.sql_type != DESTINATION_TYPE
          end

          options[:klass] ||= klass
          options[:set_primary_key] = klass.primary_key && klass.columns_hash[klass.primary_key].sql_type != DESTINATION_TYPE
          options[:references] ||= []
          options[:references].concat belongs_to_associations.map {|association| association.foreign_key }
          options[:references].uniq!

          if options[:set_primary_key]  || options[:references].size > 0
            tables[klass.table_name] = options
          end
        end

        version = Time.now.utc.strftime('%Y%m%d%H%M%S')
        prefix = Time.now.utc.strftime('%b%d').downcase
        number = 0
        tables.each do |table_name, options|
          @klass = options[:klass]
          @references = options[:references]
          @set_primary_key = options[:set_primary_key]
          @name = "#{prefix}_bigintify_#{@klass.table_name}"

          template "migration.rb.erb", "db/lhm/#{version}#{number += 1}_#{@name}.rb"
        end
      end
    end
  end
end
