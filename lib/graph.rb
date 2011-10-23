#       graph.rb
#       
#       Copyright 2011 Gintaras Sakalauskas <gintaras@Barnis>
#       
$LOAD_PATH << '.'
require 'subject.rb'
Infinity = 999999999999999999999999999999999999999999999999999
class Graph
  attr_accessor :vertices
  attr_reader :oriented
  
	def initialize(vertices = 0, oriented = true, limit = 10)
    @vertices = []
    oriented ? @oriented = true : @oriented = false
    @max_index =  vertices
    @vertices.fill(0...vertices) {|i| Vertex.new(:name => i)}
    @@trigger_limit = limit
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
    graph = self.new count, oriented ? true : false
    graph.seed_paths(min, max)
    graph
  end
  
  def seed_paths(min, max)
    @vertices.each do |from_vertex|
    t= @vertices.size * 2
      fr_neighbours = from_vertex.neighbour_count
      minimum = (min-fr_neighbours > 0 ? min-fr_neighbours : 0)
      choice = (minimum..max-fr_neighbours).to_a
      paths_to_create = choice.sample
      trigger= @@trigger_limit
      while (paths_to_create > 0)
        t -=1
        trigger -= 1        
        to_vertex= if trigger < 0
          redistribute_neighbour(to_vertex, min)
        else
          @vertices.sample
        end
        if (to_vertex != from_vertex) && !(from_vertex.neighbour? to_vertex)
          if @oriented
            add_direct_path(from_vertex, to_vertex) 
            paths_to_create -= 1
          elsif (!(@oriented)) && to_vertex.valid?(max)
            add_direct_path(from_vertex, to_vertex) 
            paths_to_create -= 1
          end
        end
        (full?(from_vertex, max) ? trigger = -1 : trigger = @@trigger_limit) if trigger == 0
        #~ if t < 0
          #~ p self
          #~ p @vertices.collect{|vertex| (vertex.valid?(max) and not(vertex(from_vertex).neighbour? vertex)) ? :a : nil}
          #~ p trigger
        #~ end 
      end
    end
  end
  
  def full?(from, max = 1)
    @vertices.collect{|vertex| (vertex.valid?(max) and not(vertex(from).neighbour? vertex)) ? :a : nil}.compact.size == 1
  end
  
  def redistribute_neighbour(to_vertex, min)
    v1 = find_good_vertex(@vertices - [to_vertex], min)
    v2 = find_good_vertex(v1.neighbours, min)
    delete_direct_path(v1, v2)
    return v1
  end
  
  def find_good_vertex(from, min)
    from= from.keys if from.class.to_s == "Hash"
    vertex= vertex(from.sample)
    while(vertex.neighbour_count <= min)
      vertex= vertex(from.sample)
    end
    return vertex
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
  
  #~ DIJSKTRA===========================================================
  #~ PESUDOCODE from Wikipedia
 #~ 1  function Dijkstra(Graph, source):
 #~ 2      for each vertex v in Graph:           // Initializations
 #~ 3          dist[v] := infinity ;              // Unknown distance function from source to v
 #~ 4          previous[v] := undefined ;         // Previous node in optimal path from source
 #~ 5      end for ;
 #~ 6      dist[source] := 0 ;                    // Distance from source to source
 #~ 7      Q := the set of all nodes in Graph ;
        #~ // All nodes in the graph are unoptimized - thus are in Q
 #~ 8      while Q is not empty:                 // The main loop
 #~ 9          u := vertex in Q with smallest dist[] ;
#~ 10          if dist[u] = infinity:
#~ 11              break ;                        // all remaining vertices are inaccessible from source
#~ 12          fi ;
#~ 13          remove u from Q ;
#~ 14          for each neighbor v of u:         // where v has not yet been removed from Q.
#~ 15              alt := dist[u] + dist_between(u, v) ;
#~ 16              if alt < dist[v]:             // Relax (u,v,a)
#~ 17                  dist[v] := alt ;
#~ 18                  previous[v] := u ;
#~ 19              fi  ;
#~ 20          end for ;
#~ 21      end while ;
#~ 22      return dist[] ;
#~ 23  end Dijkstra.
  def dijkstra start
    prepare_for_dijkstra
    @cc= Vertex.new
    @cc.distance = Infinity
    start.distance= 0
    q= @vertices.size - 1
    while q > 0
      smallest_distance(@vertices) do |u|
        return if u.distance == Infinity
        q -= 1
        u.deleted = true
        u.neighbours.each_key do |v|
          v= vertex(v)
          alt= u.distance + u.neighbours[v.name]
          if alt < v.distance
            v.distance = alt
            v.previous = u.name
          end
        end
      end
    end
  end
  
  def smallest_distance(vertices)
    min= @cc
    vertices.each do |vertex|
      min= vertex if (vertex.distance < min.distance) && (vertex.deleted == false)
    end
    yield min
  end
  
  def prepare_for_dijkstra
    @vertices.each do |vertex|
      vertex.distance= Infinity
      vertex.previous= :undefined
      vertex.deleted= false
    end
  end
  
  def print_shortest_paths vertex
    dijkstra(vertex)
    puts "Shortest paths from #{vertex.name}"
    (@vertices - [vertex]).each do |v|
      puts dikstra_path_between(vertex, v).to_s + " (#{v.distance})"
    end
  end
  
  def dikstra_path_between(from, to)
    ats = [to.name.to_s]
    #~ p to.name, to.options
    while to.previous != :undefined
      ats << to.previous.to_s
      to = vertex(to.previous)
    end
    ats.reverse.join(" => ")
  end
  #~ 
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
  
  #~ 
  #~ GRAPH COLORING================================================================

  def teacher_hash(recalculate = false)
    if recalculate or @teachers_hash.nil?
      @teachers_hash = {}
      @vertices.each do |vertex|
        if @teachers_hash[vertex.teacher]
          @teachers_hash[vertex.teacher] << vertex.name
        else
          @teachers_hash[vertex.teacher] = [vertex.name]
        end
      end
    end
    @teachers_hash
  end

  def student_hash(recalculate = false)
    if recalculate or @students_hash.nil?
      @students_hash = {}
      @vertices.each do |vertex|
        if @students_hash[vertex.student_group]
          @students_hash[vertex.student_group] << vertex.name
        else
          @students_hash[vertex.student_group] = [vertex.name]
        end
      end
    end
    @students_hash
  end

  def conflict_graph
    teacher_hash.each_value do |same_teacher_subjects|
      while same_teacher_subjects.size > 1
        subject = same_teacher_subjects.pop
        same_teacher_subjects.each { |other_subject| add_direct_path(subject, other_subject) }
      end
    end
    student_hash.each_value do |same_student_groups|
      while same_student_groups.size > 1
        student_group = same_student_groups.pop
        same_student_groups.each { |other_students| add_direct_path(student_group, other_students) }
      end
    end
  end

  def neighbour_colors(vertex)
    vertex(vertex).neighbours.keys.collect do |neighbour|
      @vertices[neighbour].color
    end.compact
  end
  

  def color_graph(colors)
    vertices.sort{|a, b| b.neighbour_count <=> a.neighbour_count}.each do |vertex|
      valid_colors = colors
      valid_colors = valid_colors - neighbour_colors(vertex) if neighbour_colors(vertex)
      vertex.color = valid_colors.sample
    end
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
