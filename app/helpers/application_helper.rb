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
    Entity.where(id: cookies[:entity_id]).first if entity_id_cookie_value
  end

  def entity_id_cookie_value
    match = /\A\d+\z/.match(cookies[:entity_id])
    return Integer(match[0]) if match
  end

  def suppress_ajax_redirect?
    return cookies[:no_ajax].present? unless params[:no_ajax].present?

    if html_true?(params[:no_ajax])
      cookies[:no_ajax] = 1
      true
    else
      cookies.delete(:no_ajax)
      false
    end
  end

  def html_true?(value)
    %w(1 true yes).include?(value)
  end
end
