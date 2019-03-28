# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Ensure Search indexes
[User, Group, Repository, Doc, Note].each do |klass|
  unless klass.__elasticsearch__.index_exists?
    klass.__elasticsearch__.create_index!
  end
end