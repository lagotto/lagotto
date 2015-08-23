class MonthInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    template.select_month(object.month, { include_blank: true }, name: "work[month]", id: "work_month")
  end
end
