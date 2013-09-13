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
      when /the (.*) table/ then "##{$1}_table"
      when /the account row for "([^"]+)"/ then "#account_#{account_id($1)}"
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
  
  private
    def account_id(name)
      account = Account.find_by_name(name)
      raise "No account found with name=#{name}" unless account
      account.id
    end
end
World(NavigationHelpers)