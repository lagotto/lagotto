
def determine_revision
  # Note the revision we're running
  revisionFile = Rails.root + "/REVISION"
  digits = 8
  Rails.env + begin
    " " + File.read(revisionFile)[0...digits]
  rescue
    begin
      " #{`git log -1`.split(" ")[1][0...digits]} #{`git branch`.split("\n")[0].split(" ")[-1]}"
    rescue
      ""
    end
  end
end 
SOURCE_REVISION = determine_revision
