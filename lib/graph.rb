#       graph.rb
#       
#       Copyright 2011 Gintaras Sakalauskas <gintaras@Barnis>
#       
$LOAD_PATH << '.'
require 'vertex.rb'

class Graph
  attr_accessor :vertices
  attr_reader :oriented
  
	def initialize(vertices = nil, oriented = true)
    @vertices = {}
    oriented ? @oriented = true : @oriented = false 
    vertices.each{ |v| add_vertex(v) } if vertices
	end
  
  def add_vertex(u)
    if u.class.to_s == 'Array'
      u.each { |v| add_vertex(v) }
    else
      if u.class.to_s == 'Vertex'
        u.name = current_last
        @vertices[current_last] = u 
      end
    end
  end
  
  def path_weight(from, to)
    convert_to_vertices(from, to) do |from, to|
      from.routes[to.name]
    end
  end
  
  def change_weight(from, to, weight)
    convert_to_vertices(from, to) do |from, to|
      from.routes[to.name] = weight
    end
  end
  #~ RANDOM GRAPH=======================================================

    
  def self.random(count, min=1, max=1, oriented = true)
    graph = self.new count.times.collect{ Vertex.new }, oriented ? true : false 
    graph.seed_paths(min, max)
    graph
  end
  
  def seed_paths(min, max)
    @vertices.each_value do |from_vertex|
      paths_to_create = (min..max).to_a.shuffle.first
      random_vertices do |to_vertex|
        break if paths_to_create == 0
        if valid_for_path?(from_vertex, to_vertex, max)
          add_direct_path(from_vertex, to_vertex)
          paths_to_create -= 1
        else
          next
        end
      end
    end
  end
  #~ NEIGHBOURS=========================================================
  def neighbours?(from, to)
    convert_to_vertices(from, to) do |from, to|
      from.neighbour?(to)
    end
  end
  
  def add_direct_path(from, to, weight = 1)
    convert_to_vertices(from, to) do |from, to|
      add_if_missing from
      add_if_missing to
      from.add_neighbour(to, weight)
      to.add_neighbour(from, weight) unless @oriented
    end
  end
  
  def delete_direct_path(from, to)
    convert_to_vertices(from, to) do |from, to|
      from.remove_neighbour(to)
      to.remove_neighbour(from) unless @oriented
    end
  end
  
  def neighbours(u)
    u.neighbours
  end
  #~ VERTICE NUMBERS====================================================
  def change_vertex_number(from, to)
    unless @vertices.key? to
      from = vertex(from)
      @vertices.each_value {|v| v.rename_neighbour(from, to)}
      @vertices[to] = from
      @vertices.delete from.name
      from.name = to
    end
  end
  #~ OUTPUT functions===================================================
  def to_s
    @vertices.each do |vertex|
      p vertex
    end
  end
  
  def print_neighbours(u)
    neighbours(u).each do |nb|
      puts nb.name
    end
  end
  #~ COUNT functions====================================================
  def current_last
    @vertices.size > 0 ? @vertices.keys.max + 1 : 0
  end
  
  def vertice_count
    current_last
  end
  
  #~ DFS================================================================
  def dfs
    @timer = 0
    prepare_vertices
    #~ p @vertices[0]
    @vertices.each_value do |vertex|
      dfs_visit(vertex) if vertex.color == :white
      break
    end
  end
  
  def dfs_visit vertex
    vertex.color = :grey
    @timer += 1
    vertex.visited_at = @timer
    vertex.neighbours.each_value do |neighbour|
      if neighbour.color == :white
        neighbour.parent = vertex.name
        dfs_visit neighbour
      end
    end
    vertex.color = :black
    @timer += 1
    vertex.cleared_out = @timer
  end
  
  def jungus?
    dfs
    @vertices.collect { |key, vertex| vertex.parent.nil? ? true : nil }.compact.size == 1
  end
  
  private
  
  def convert_to_vertices(from, to)
    from= vertex(from)
    to= vertex(to)
    yield from, to
  end
  
  def vertex(nr)
    return nr.instance_of?(Fixnum) ? @vertices[nr] : nr
  end
  
  def random_vertices
    @vertices.keys.shuffle.each {|i| yield @vertices[i]}
  end
  
  def add_if_missing(v)
    add_vertex(v) unless @vertices.values.include? v
  end
  
  def valid_for_path?(from, to, max)
    to.valid?(max) && from.valid?(max) && from != to
  end
  
  def prepare_vertices
    reset_vertices
    @vertices.each_value do |vertex|
      vertex.color = :white
      vertex.parent = nil
    end
  end
  
  def reset_vertices
    @vertices.each_value { |v| v.reset_options }
  end
end
