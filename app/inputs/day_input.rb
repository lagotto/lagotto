class DayInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    template.select_day(object.day, { include_blank: true }, name: "work[day]", id: "work_day")
  end
end
