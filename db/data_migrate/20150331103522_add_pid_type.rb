class AddPidType < ActiveRecord::Migration
  def up
    # url (http) and ark already have prefix
    Work.where("pid_type NOT IN (?)", ["url","ark"]).update_all("pid = CONCAT(pid_type, ':', pid)")
  end

  def down
    # only works if pid_type is doi
    Work.update_all("pid = doi")
  end
end
