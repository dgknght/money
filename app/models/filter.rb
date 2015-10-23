class Filter
  include ActiveModel::Validations
  
  def Filter.date_value(value, default = Date.today)
    return default unless value
    if value.is_a?(Date)
      value
    else
      Chronic.parse(value.to_s).to_date
    end
  rescue
    # just use the default
    default
  end
end
