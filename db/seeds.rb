# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if User.count == 0
  admin = User.create!(slug: "admin", email: "admin@booklab.io", password: "123456", password_confirmation: "123456")
end

if Group.count == 0
  Group.create!(slug: "sample", name: "Sample Group", creator_id: User.first.id)
end