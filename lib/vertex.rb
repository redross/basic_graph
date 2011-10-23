#       vertex.rb
#       
#       Copyright 2011 Gintaras Sakalauskas <gintaras@Barnis>
#       

class Vertex
	attr_accessor :neighbours, :routes, :name, :options, :teacher, :discipline, :student_group, :real_name
  
  def initialize options = {} #name = nil, teacher, discipline, student_group
    @neighbours = {}
    @options = {} #a
    @name =  options[:name]
    @real_name =  options[:real_name]
    @teacher =  options[:teacher]
    @discipline =  options[:discipline]
    @student_group =  options[:student_group]
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
      self.class.send :define_method, m.to_sym do |value|
        @options[m[0...m.length - 1].to_sym]= value
      end
      self.send(m, args.first)
    else
      self.class.send :define_method, m.to_sym do
        @options[m[0...m.length].to_sym]
      end
      self.send(m)
    end
  end
end
