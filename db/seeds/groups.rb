# encoding: UTF-8
# Load groups
viewed = Group.find_or_create_by_name(name: "viewed", display_name: "Viewed")
saved = Group.find_or_create_by_name(name: "saved", display_name: "Saved")
discussed = Group.find_or_create_by_name(name: "discussed", display_name: "Discussed")
cited = Group.find_or_create_by_name(name: "cited", display_name: "Cited")
recommended = Group.find_or_create_by_name(name: "recommended", display_name: "Recommended")
other = Group.find_or_create_by_name(name: "other", display_name: "Other")