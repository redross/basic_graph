#       main.rb
#       
#       Copyright 2011 Gintaras Sakalauskas <gintaras@Barnis>
#
$LOAD_PATH << './lib'
require 'graph.rb'
     
#~ @graph = Graph.new 7, false
#~ @graph.add_direct_path(0, 1)
#~ @graph.add_direct_path(0, 2)
#~ @graph.add_direct_path(1, 4)
#~ @graph.add_direct_path(2, 3)
#~ @graph.add_direct_path(3, 4)
#~ @graph.add_direct_path(3, 5)
#~ @graph.add_direct_path(3, 6)
#~ @graph.add_direct_path(5, 6)
#~ 
#~ if @graph.jungus?
  #~ puts "Grafas jungus"
#~ else
  #~ puts "Grafas nera jungus"
#~ end
#~ 
#~ puts "Apeitas kelias:"
#~ puts @graph.dfs_path

#~ @graph = Graph.new 6, false
#~ @graph.add_direct_path(0, 1, 5)
#~ @graph.add_direct_path(0, 2, 10)
#~ @graph.add_direct_path(1, 3, 2)
#~ @graph.add_direct_path(2, 3, 25)
#~ @graph.add_direct_path(2, 5, 4)
#~ @graph.add_direct_path(3, 4, 10)
#~ @graph.add_direct_path(4, 5, 1)
#~ @graph.dijkstra @graph.vertices[0]

#~ @graph= Graph.new 6, true
#~ @graph.add_direct_path(0, 1, 70)
#~ @graph.add_direct_path(0, 2, 50)
#~ @graph.add_direct_path(0, 4, 100)
#~ @graph.add_direct_path(1, 3, 35)
#~ @graph.add_direct_path(1, 5, 20)
#~ @graph.add_direct_path(2, 1, 60)
#~ @graph.add_direct_path(2, 3, 15)
#~ @graph.add_direct_path(3, 4, 30)
#~ @graph.add_direct_path(3, 5, 45)
#~ @graph.add_direct_path(4, 2, 20)
#~ @graph.add_direct_path(5, 4, 4)




#~ @graph.dijkstra @graph.vertices[0]
#~ puts "Apeitas kelias:"
#~ puts @graph.dfs_path
#~ @graph.vertices.each {|v| puts "I #{v.name} atejom is #{v.previous} (atstumas nuo starto #{v.distance})" }
