# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



main_categories = ['Equipements de promenade',
                    'Jouets',
                    'Lits, équipements d\'intérieur',
                    'Repas, allaitement',
                    'Toilette',
                    'Vêtements, accessoires']

main_categories.each do |name|
  main = Category.create(name: name)
  case name
  when 'Equipements de promenade'
    Category.create([{ name: 'Porte-bébés', main_category_id: main.id },
                     { name: 'Poussettes, systèmes combinés', main_category_id: main.id },
                     { name: 'Sacs à langer', main_category_id: main.id },
                     { name: 'Sièges: auto, vélo', main_category_id: main.id },
                     { name: 'Autres', main_category_id: main.id }])
  when 'Jouets'
    Category.create([{ name: 'Eveil', main_category_id: main.id },
                     { name: 'Jeux d\'eau', main_category_id: main.id },
                     { name: 'Jeux d\'emboîtage', main_category_id: main.id },
                     { name: 'Jeux préscolaires', main_category_id: main.id },
                     { name: 'Jouets à traîner', main_category_id: main.id },
                     { name: 'Mini-univers', main_category_id: main.id },
                     { name: 'Mobiles', main_category_id: main.id },
                     { name: 'Trotteurs, porteurs', main_category_id: main.id },
                     { name: 'Autres', main_category_id: main.id }])
  when 'Lits, équipements d\'intérieur'
    Category.create([{ name: 'Chambres complètes', main_category_id: main.id },
                     { name: 'Décorations, veilleuses', main_category_id: main.id },
                     { name: 'Gigoteuses, nids d\'anges', main_category_id: main.id },
                     { name: 'Literie', main_category_id: main.id },
                     { name: 'Meubles', main_category_id: main.id },
                     { name: 'Meubles à langer', main_category_id: main.id },
                     { name: 'Parcs', main_category_id: main.id },
                     { name: 'Transats, balancelles', main_category_id: main.id },
                     { name: 'Autres', main_category_id: main.id }])
  when 'Equipements de promenade'
    Category.create([{ name: 'Porte-bébés', main_category_id: main.id },
                     { name: 'Poussettes, systèmes combinés', main_category_id: main.id },
                     { name: 'Sacs à langer', main_category_id: main.id },
                     { name: 'Sièges: auto, vélo', main_category_id: main.id },
                     { name: 'Autres', main_category_id: main.id }])
  when 'Repas, allaitement'
    Category.create([{ name: 'Accessoires repas', main_category_id: main.id },
                     { name: 'Allaitement', main_category_id: main.id },
                     { name: 'Biberons, chauffe-biberons', main_category_id: main.id },
                     { name: 'Stérilisateurs', main_category_id: main.id },
                     { name: 'Autres', main_category_id: main.id }])
  when 'Toilette'
    Category.create([{ name: 'Bain', main_category_id: main.id },
                     { name: 'Accessoires', main_category_id: main.id },
                     { name: 'Couches, changes', main_category_id: main.id },
                     { name: 'Meubles à langer', main_category_id: main.id },
                     { name: 'Mouche-bébés', main_category_id: main.id },
                     { name: 'Pèse-bébés', main_category_id: main.id },
                     { name: 'Produits de toilette', main_category_id: main.id },
                     { name: 'Autres', main_category_id: main.id }])
  when 'Vêtements, accessoires'
    Category.create([{ name: 'Accessoires', main_category_id: main.id },
                     { name: 'Vêtements de baptême', main_category_id: main.id },
                     { name: 'Vêtements garçons (0-24 mois)', main_category_id: main.id },
                     { name: 'Vêtements filles (0-24 mois)', main_category_id: main.id },
                     { name: 'Chaussures', main_category_id: main.id },
                     { name: 'Vêtements de maternité', main_category_id: main.id },                     
                     { name: 'Autres', main_category_id: main.id }])
  end
end