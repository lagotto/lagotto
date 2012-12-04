### GIVEN ###

### WHEN ###
When /^I pipe in the file "(.*?)"$/ do |file|
  in_current_dir do
    File.open(file, 'r').each_line do |line|
      _write_interactive(line)
    end
  end
  @interactive.stdin.close()
end

### THEN ###

