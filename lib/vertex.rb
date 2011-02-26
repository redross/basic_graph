#       vertex.rb
#       
#       Copyright 2011 Gintaras Sakalauskas <gintaras@Barnis>
#       

class Vertex
	attr_accessor :neighbours, :routes, :name
  
  def initialize
    @neighbours = {}
    @routes = {}
    @name= nil
  end
  
  def neighbour? v
    @neighbours.include? v.name
  end
  
  def add_neighbour v, weight
    @neighbours[v.name]= v
    @routes[v.name] = weight
  end
  
  def remove_neighbour v
    @neighbours.delete(v.name)
    @routes.delete(v.name)
  end
  
  def rename_neighbour from, to
    if neighbour? from
      @neighbours[to]= from
      @routes[to] = @routes[from.name]
      remove_neighbour from
    end
  end
  
  def neighbour_count
    @neighbours.size
  end
  
  def valid? max
    neighbour_count < max
  end
end
