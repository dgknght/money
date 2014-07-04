class Filter
  include ActiveModel::Validations
  
  def self.date_value(value, default = Date.today)
    if value
      begin
        return value.is_a?(Date) ? value : Date.parse(value.to_s)
      rescue
        # just use the default
      end
    end
    default
  end
end