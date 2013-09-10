module NavigationHelpers
  def locator_for(section)
    case section
      when /the success notification area' then "#success"
      else then raise "Unrecognized section #{section}"
    end
  end
end
World(NavigationHelpers)