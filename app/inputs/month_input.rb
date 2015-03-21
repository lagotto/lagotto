class MonthInput < SimpleForm::Inputs::Base
  def input
    template.select_month(object.month, { include_blank: true }, name: "work[month]", id: "work_month")
  end
end
