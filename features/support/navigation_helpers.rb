module NavigationHelpers
  def description_to_id(description)
    description.gsub(' ', '_').downcase
  end
  
  def locator_for(section)
    case section
      when /the success notification area/ then "#success"
      when /the page title/ then "#page_title"
      else raise "Unrecognized section \"#{section}\""
    end
  end
  
  def parse_table(table_elem)
    rows = table_elem.all('tr')
    rows.map { |r| r.all('th,td').map { |c| c.text.strip} }
  end
  
  def path_for(page_identifier)
    case page_identifier
      when "the home" then "/"
      else raise "unrecognized page identifier \"#{page_identifier}\""
    end
  end
end
World(NavigationHelpers)