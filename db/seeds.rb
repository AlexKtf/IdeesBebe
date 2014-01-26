# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



main_categories = ["Vêtements, accessoires",
                   "Eveil & jeux",
                   "Transport",
                   "Le coin des mamans",
                   "Maison"]

main_categories.each do |name|
  main = Category.create(name: name)
  case name
  when "Eveil & jeux"
    Category.create([{ name: 'Peluches, doudous', main_category_id: main.id }, { name: 'Jouets 1er âge', main_category_id: main.id }])
  when "Transport"
    Category.create([{ name: 'Equipements de promenade', main_category_id: main.id }])
  when "Maison"
    Category.create([{ name: 'Sécurité', main_category_id: main.id },
                     { name: 'Toilette, bain', main_category_id: main.id },
                     { name: 'Repas, allaitement', main_category_id: main.id },
                     { name: "Lits, équipements d'intérieur", main_category_id: main.id } ])
  end
end