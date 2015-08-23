class YearInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    template.select_year(object.year, { start_year: 1650, end_year: Time.zone.now.year }, name: "work[year]", id: "work_year")
  end
end
