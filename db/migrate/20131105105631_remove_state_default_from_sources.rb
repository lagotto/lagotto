class RemoveStateDefaultFromSources < ActiveRecord::Migration
  def up
    # Remove default from state column as this causes an error to be thrown:  "Both Source and its :state machine have defined a different default for "state". Use only one or the other for defining defaults to avoid unexpected behaviors."
    # See this page for more information: https://github.com/pluginaweek/state_machine/issues/279
    change_column_default(:sources, :state, nil)
  end

  def down
    change_column_default(:sources, :state, 0)
  end
end
