# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# We have created individual seeds files for each model, and have put them into the db/seeds/production directory

include Sprig::Helpers

sprig [WorkType, RelationType, Report, Filter, RegistrationAgency, Group, Source, Agent, ContributorRole]
