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
    query = <<-SQL
    SELECT
      #{self.table_name}.*
    FROM
      #{self.table_name}
    SQL
    self.parse_all(DBConnection.execute(query))
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    query = <<-SQL
    SELECT
      #{self.table_name}.*
    FROM
      #{self.table_name}
    WHERE
      id = ?
    SQL
    self.parse_all(DBConnection.execute(query, id)).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_sym = attr_name.to_sym
      unless self.class::columns.include?(attr_sym)
        raise Exception.new("unknown attribute '#{attr_sym}'")
      else
        send("#{attr_name}=", value)
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class::columns.map { |column| self.send(column) }
  end

  def insert
    col_names = self.class::columns.join(',')
    question_marks = (["?"] * self.class::columns.length).join(',')
    query = <<-SQL
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})
    SQL
    DBConnection.execute(query, *attribute_values)
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class::columns.map { |col| "#{col} = ?"}.join(',')
    query = <<-SQL
    UPDATE
      #{self.class.table_name}
    SET
      #{set_line}
    WHERE
      id = ?
    SQL
    DBConnection.execute(query, *attribute_values, self.id)
  end

  def save
    if id.nil?
      insert
    else
      update
    end
  end
end
