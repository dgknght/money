module ApplicationHelper
  def current_entity
    @current_entity ||= lookup_current_entity
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

  def format_price(value)
    number_to_currency(value, unit: '', precision: 4)
  end

  def format_shares(value)
    number_to_currency(value, unit: '', precision: 4)
  end

  def lookup_current_entity
    Entity.find(cookies[:entity_id]) if cookies[:entity_id]
  end
end
