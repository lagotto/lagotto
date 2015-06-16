class ChangePidToUrl < ActiveRecord::Migration
  def up
    # wos and scp don't have corresponding URL (yet), so will ignore
    Work.where("pid_type = doi").update_all("pid = CONCAT('http://doi.org/', doi)")
    Work.where("pid_type = pmid").update_all("pid = CONCAT('http://www.ncbi.nlm.nih.gov/pubmed/', pmid)")
    Work.where("pid_type = pmcid").update_all("pid = CONCAT('http://www.ncbi.nlm.nih.gov/pmc/articles/PMC', pmcid)")
    Work.where("pid_type = arxiv").update_all("pid = CONCAT('http://arxiv.org/abs/', arxiv)")
    Work.where("pid_type = ark").update_all("pid = CONCAT('http://n2t.net/', ark)")
  end

  def down
  end
end
