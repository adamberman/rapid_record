require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    table_info = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    table_info[0].map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |column|
      define_method "#{column}" do
        attributes[column]
      end
      define_method "#{column}=" do |val|
        attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    instance_variable_set("@table_name", table_name)
  end

  def self.table_name
    name = instance_variable_get("@table_name")
    name = self.to_s.tableize if name.nil?
    name
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    # ...
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
