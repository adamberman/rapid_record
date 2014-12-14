module Searchable
  def where(params)
    where_line = params.keys.map { |key| "#{key} = ?"}.join(' AND ')
    values = params.values
    query = <<-SQL
    SELECT
    	*
    FROM
    	#{table_name}
    WHERE
    	#{where_line}
    SQL
    parse_all(DBConnection.execute(query, *values))
  end
end