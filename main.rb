#       main.rb
#       
#       Copyright 2011 Gintaras Sakalauskas <gintaras@Barnis>
#
$LOAD_PATH << './lib'
require 'graph.rb'


graph = Graph.new 0, false
subject_1 = Subject.new('Greg Pollack', 'Ruby on Rails with zombies')     
subject_2 = Subject.new('Ryan Bigg', 'Ruby on Rails screncasting')     
subject_3 = Subject.new('Andrius Chamentauskas', 'Metametaprogramming')     
subject_4 = Subject.new('Saulius Grigaitis', 'Deploying Ruby on Rails')

graph.add_vertices(Subject.generate_vertices(subject_1, ['IT 1st. sem.', 'PS 1st. sem.', 'MIM 2nd. sem.']))     
graph.add_vertices(Subject.generate_vertices(subject_2, ['IT 2st. sem.', 'PS 1st. sem.', 'MIM 2nd. sem.']))     
graph.add_vertices(Subject.generate_vertices(subject_3, ['IT 4th. sem.', 'PS 2nd. sem.']))     
graph.add_vertices(Subject.generate_vertices(subject_4, ['IT 3rd. sem.', 'PS 2nd. sem.']))

days = [:monday, :tuesday, :thursday]
lessons = [:"1st", :"2nd", :"3rd", :"4th"]

colors = days.product(lessons).map {|x| x.join("_")}

graph.conflict_graph
graph.color_graph(colors) 

graph.vertices.each {|v| puts "Dalykas: #{v.real_name}: #{v.color}"}    
