#       main.rb
#       
#       Copyright 2011 Gintaras Sakalauskas <gintaras@Barnis>
#
$LOAD_PATH << './lib'
require 'graph.rb'
     
@graph = Graph.new 7, false
@graph.add_direct_path(0, 1)
@graph.add_direct_path(0, 2)
@graph.add_direct_path(1, 4)
@graph.add_direct_path(2, 3)
@graph.add_direct_path(3, 4)
@graph.add_direct_path(3, 5)
@graph.add_direct_path(3, 6)
@graph.add_direct_path(5, 6)

if @graph.jungus?
  puts "Grafas jungus"
else
  puts "Grafas nera jungus"
end

puts "Apeitas kelias:"
puts @graph.dfs_path
