module NavigationHelpers
  def locator_for(section)
    case section
      when /the success notification area/ then "#success"
      else raise "Unrecognized section \"#{section}\""
    end
  end
  
  def path_for(page_identifier)
    case page_identifier
      when "home" then "/"
      else raise "unrecognized page identifier \"#{page_identifier}\""
    end
  end
end
World(NavigationHelpers)