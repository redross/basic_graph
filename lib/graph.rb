#       graph.rb
#       
#       Copyright 2011 Gintaras Sakalauskas <gintaras@Barnis>
#       
$LOAD_PATH << '.'
require 'vertex.rb'

class Graph
  attr_accessor :vertices, :valid_indexes
  attr_reader :oriented
  
	def initialize(vertices = 0, oriented = true)
    @vertices = []
    @valid_indexes = []
    oriented ? @oriented = true : @oriented = false
    @max_index =  vertices
    @vertices.fill(0...vertices) {|i| Vertex.new(i)}
    @valid_indexes.fill(0...vertices) {|i| i}
	end
  
  def add_vertices(u)
    if u.class.to_s == 'Array'
      u.each { |v| add_vertex(v) }
    end
  end
  
  def add_vertex(u)
    if u.class.to_s == 'Vertex'
      u.name = current_last
      @vertices[current_last] = u
      @valid_indexes << u.name
      @max_index += 1
    end 
  end
  
  def path_weight(from, to)
    convert_to_vertices(from, to) do |from, to|
      from.neighbours[to.name]
    end
  end
  
  def change_weight(from, to, weight)
    convert_to_vertices(from, to) do |from, to|
      from.neighbours[to.name] = weight
    end
  end
  #~ RANDOM GRAPH=======================================================

    
  def self.random(count, min=1, max=1, oriented = true)
    #~ graph = self.new count.times.collect{ Vertex.new }, oriented ? true : false 
    graph = self.new count, oriented ? true : false 
    graph.seed_paths(min, max)
    graph
  end
  
  def seed_paths(min, max) #2 5
    @vertices.each do |from_vertex|
      fr_neighbours = from_vertex.neighbour_count # 2
      minimum = (min-fr_neighbours > 0 ? min-fr_neighbours : 0)
      #~ maximimum = max-fr_neighbours > 0 ? max-fr_neighbours : 0
      choice = (minimum..max-fr_neighbours).to_a
      paths_to_create = choice.sample
      valid_vertices(paths_to_create, from_vertex) do |to_vertex|
        break if to_vertex.nil?
        add_direct_path(from_vertex, to_vertex, 1, max)
        paths_to_create -= 1
      end
    end
  end
  #~ NEIGHBOURS=========================================================
  def neighbours?(from, to)
    convert_to_vertices(from, to) do |from, to|
      from.neighbour?(to)
    end
  end
  
  def add_direct_path(from, to, weight = 1, max = nil)
    convert_to_vertices(from, to) do |from, to|
      add_if_missing from
      add_if_missing to
      from.add_neighbour(to, weight)
      unless @oriented 
        to.add_neighbour(from, weight) unless @oriented
        if max
          unless to.valid?(max)
            @valid_indexes.delete(to.name)
          end
        end
      end
      (@valid_indexes.delete(from.name) unless from.valid?(max)) if max
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
    unless @vertices[to]
      from = vertex(from)
      @vertices.each {|v| v.rename_neighbour(from, to)}
      @vertices[to] = from
      @vertices.delete from.name
      from.name = to
      @max_index = to + 1 if @max_index < to
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
    @max_index
    #~ @vertices.size > 0 ? @vertices.keys.max + 1 : 0
  end
  
  def vertice_count
    #~ current_last
    @vertices.size
  end
  
  #~ DFS================================================================
  def dfs
    @timer = 0
    prepare_vertices
    @vertices.each do |vertex|
      dfs_visit(vertex) if vertex.color == :white
      break
    end
  end
  
  def dfs_visit vertex
    vertex.color = :grey
    @timer += 1
    vertex.visited_at = @timer
    vertex.neighbours.each_key do |neighbour|
      if vertex(neighbour).color == :white
        vertex(neighbour).parent = vertex.name
        dfs_visit vertex(neighbour)
      end
    end
    vertex.color = :black
    @timer += 1
    vertex.cleared_out = @timer
  end
  
  def jungus?
    dfs
    @vertices.collect { |vertex| vertex.parent.nil? ? true : nil }.compact.size == 1
  end
  
  def dfs_path
    dfs
    path = []
    @vertices.each do |vertex|
      path[vertex.visited_at.to_i] = vertex.name if vertex.visited_at
    end
    path.compact.join(' -> ') 
  end
  
  def valid_vertices(n, from)
    #~ indexes = []
    #~ @vertices.each_index do |i|
      #~ indexes << i
    #~ end
    yield nil if n.nil? || n == 0
    (@valid_indexes - [from.name]).sample(n).each {|i| yield @vertices[i]}
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
    indexes = []
    @vertices.each_index do |i|
      indexes << i
    end
    indexes.shuffle.each {|i| yield @vertices[i]}
  end
  

  
  def add_if_missing(v)
    add_vertex(v) unless @vertices.include? v
  end
  
  def prepare_vertices
    reset_vertices
    @vertices.each do |vertex|
      vertex.color = :white
      vertex.parent = nil
    end
  end
  
  def reset_vertices
    @vertices.each { |v| v.reset_options }
  end
end
