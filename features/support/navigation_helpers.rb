module NavigationHelpers
  def description_to_id(description)
    description.gsub(' ', '_').downcase
  end

  def locator_for(section)
    case section
      when /the notice area/ then ".notice"
      when /the page title/ then "#page_title"
      when /the page subtitle/ then "#page_subtitle"
      when /the main content/ then "#content"
      when /the navigation/ then "nav"
      when /the secondary navigation/ then "#nav_2"
      when /the (.*) table/ then "##{$1}_table"
      when /the account row for "([^"]+)"/ then "#account_#{account_id($1)}"
      when /the entity row for "([^"]+)"/ then "#entity_#{entity_id($1)}"
      else raise "Unrecognized section \"#{section}\""
    end
  end

  def ordinal_to_index(ordinal)
    ordinal.to_i - 1
  end

  def path_for(page_identifier)
    case page_identifier
      when "the home" then "/"
      when "my home" then  "/home"
      when /the "([^"]+)" entity/ then entity_path(find_entity($1))
      else raise "unrecognized page identifier \"#{page_identifier}\""
    end
  end
  
  private
    def account_id(name)
      account = Account.find_by_name(name)
      raise "No account found with name=#{name}" unless account
      account.id
    end
    
    def entity_id(name)
      find_entity(name).id
    end
    
    def find_entity(name)
      entity = Entity.find_by_name(name)
      raise "No entity found with name=#{name}" unless entity
      entity
    end
end
World(NavigationHelpers)