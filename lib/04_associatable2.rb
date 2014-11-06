require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method "#{name}" do
    	through_options = self.class.assoc_options[through_name]
    	source_options = through_options.model_class.assoc_options[source_name]
    	middle_table = through_options.table_name
    	far_table = source_options.model_class.table_name
    	#through is owner
    	#source is house
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
end
