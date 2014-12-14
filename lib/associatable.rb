require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || (name.to_s + "Id").underscore.to_sym
    @class_name = options[:class_name] || name.to_s.camelcase
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || (self_class_name.to_s.singularize + "Id").underscore.to_sym
    @class_name = options[:class_name] || name.to_s.camelcase.singularize
    @primary_key = options[:primary_key] || :id 
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method "#{name}" do
      foreign_key = send(options.foreign_key)
      options
        .model_class
        .where(options.primary_key => foreign_key)
        .first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method "#{name}" do
      primary_key = send(options.primary_key)
      options
        .model_class
        .where(options.foreign_key => primary_key)
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method "#{name}" do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      middle_table = through_options.table_name
      far_table = source_options.model_class.table_name
      query = <<-SQL
      SELECT
        #{far_table}.*
      FROM
        #{middle_table}
      JOIN
        #{far_table}
      ON
        #{middle_table}.#{source_options.foreign_key} = #{far_table}.#{source_options.primary_key}
      WHERE
        #{middle_table}.#{through_options.primary_key} = ?
      SQL
      source_options.model_class.parse_all(DBConnection.execute(query, send(through_options.primary_key))).first
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end
