module NavigationHelpers
  def description_to_id(description)
    description.gsub(' ', '_').downcase
  end
  
  def locator_for(section)
    case section
      when /the notice area/ then ".notice"
      when /the page title/ then "#page_title"
      when /the main content/ then "#content"
      when /the navigation/ then ".nav"
      else raise "Unrecognized section \"#{section}\""
    end
  end
  
  def path_for(page_identifier)
    case page_identifier
      when "the home" then "/"
      when "my home" then  "/home"
      else raise "unrecognized page identifier \"#{page_identifier}\""
    end
  end
end
World(NavigationHelpers)