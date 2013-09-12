module ContentHelpers
  def parse_table(table_elem)
    rows = table_elem.all('tr')
    rows.map { |r| r.all('th,td').map { |c| c.text.strip} }
  end  
end
World(ContentHelpers)