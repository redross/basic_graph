#       vertex.rb
#       
#       Copyright 2011 Gintaras Sakalauskas <gintaras@Barnis>
#       

class Vertex
	attr_accessor :neighbours, :routes, :name, :options
  
  def initialize name = nil
    @neighbours = {}
    @options = {} #a
    @name= name if name
  end
  
  def neighbour? v
    @neighbours.include? v.name
  end
  
  def add_neighbour v, weight
    @neighbours[v.name]= weight
    #~ @routes[v.name] = weight
  end
  
  def remove_neighbour v
    @neighbours.delete(v.name)
    #~ @routes.delete(v.name)
  end
  
  def rename_neighbour from, to
    if neighbour? from
      @neighbours[to]= @neighbours[from.name]
      #~ @routes[to] = @routes[from.name]
      remove_neighbour from
    end
  end
  
  def neighbour_count
    @neighbours.size
  end
  
  def valid? max
    neighbour_count < max
  end
  
  def reset_options
    @options = {}
  end
  
  def method_missing(m, *args, &block)
    m = m.to_s
    if m[m.length - 1] == '='
      #~ puts "For debug... 'Adding to options' TO DO: remove"
      @options[m[0...m.length - 1].to_sym]= args.first
    else
      #~ puts "For debug... 'Reading from options' TO DO: remove"
      @options[m[0...m.length].to_sym]
    end
  end
end
