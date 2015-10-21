module ApplicationHelper
  def current_entity
    @current_entity ||= lookup_current_entity
  end
  
  def current_entity=(entity)
    @current_entity = entity
  end
  
  def flash_key_to_bootstrap_class(key)
    level = {notice: 'success'}.fetch(key, key)
    "alert alert-#{level}"
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

  def html_true?(value)
    %w(1 true yes).include?(value)
  end

  def edit_link(path, title)
    link_to(path, class: 'btn btn-default btn-xs', title: title) do
      content_tag :span, nil, class: 'glyphicon glyphicon-pencil', aria: {hidden: 'true'}
    end
  end

  def delete_link(path, title, confirm)
    button_to(path, { method: :delete, class: 'btn btn-default btn-xs', title: title }, data: { confirm: confirm }) do
      content_tag :span, nil, class: 'glyphicon glyphicon-remove', area: {hidden: 'true'}
    end
  end
end
