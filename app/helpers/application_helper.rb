module ApplicationHelper
  def current_entity
    @current_entity
  end
  
  def current_entity=(entity)
    @current_entity = entity
  end
  
  def format_currency(value)
    number_to_currency(value, unit: '')
  end
  
  def format_date(value)
    value.nil? ? '' : value.strftime('%-m/%-d/%Y')
  end
end
