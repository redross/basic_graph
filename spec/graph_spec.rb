require 'graph'
require 'benchmark'

RSpec::Matchers.define :take_less_than do |n|
  chain :seconds do; end

  match do |block|
    @elapsed = Benchmark.realtime do
      block.call
    end
    @elapsed <= n
  end
  
  failure_message_for_should_not do |actual|
    "expected that task would take more than #{expected} seconds, but it took #{@elapsed} "
  end
  
  failure_message_for_should do |actual|
    "expected that task would not take more than #{expected} seconds, but it took #{@elapsed} "
  end
end

describe "Graphs" do
  describe "Graph" do
    before :each do
      @graph = Graph.new
      @vertex = Vertex.new
    end
    
    describe "initialize" do
      it "should default to empty graph if no parameters given" do
        @graph.vertices.should == []
      end
      
      describe "valid vertices" do
        it "should be all vertices" do
          @r_graph = Graph.new 50
          @r_graph.valid_indexes.size.should == 50
        end
      end
      
    end
    
    describe "adding vertices" do
      it "should increase the number of vertices" do
        expect{ 
          @graph.add_vertex(@vertex)
        }.to change{ @graph.vertice_count }.by(1)
      end
      
      it "should not allow adding non vertex objects" do
        expect{ 
          @graph.add_vertex("vertex")
        }.to_not change{ @graph.vertice_count }
      end
      
      describe "not existing in graph" do
        it "should be added to the graph if a path to it is created" do
          @u = Vertex.new
          @graph.add_vertex(@vertex)
          expect{
            @graph.add_direct_path(@u, @vertex)
          }.to change{ @graph.vertice_count }.from(1).to(2)
        end
        
        it "should be added to the graph if a path to it is created" do
          @u = Vertex.new
          expect{
            @graph.add_direct_path(@u, @vertex)
          }.to change{ @graph.vertice_count }.from(0).to(2)
        end
      end
      
      describe "valid indexes" do
        it "should increase count" do
          @v = Vertex.new
          expect{
            @graph.add_vertex(@v)
          }.to change {@graph.valid_indexes.size}.by(1)
        end
        
        it "should not include itself index" do
          @v = Vertex.new
          @u = Vertex.new
          @i = Vertex.new
          @graph.add_vertices [@v, @u, @i]
          @graph.valid_vertices(2, @u) do |vertex|
            vertex.should_not == @u
          end
        end
      end
    end
    
    describe "vertex validation" do
      before :each do
        @graph.add_vertex(@vertex)
        @u = Vertex.new
        @v = Vertex.new
        @graph.add_vertex(@u)
        @graph.add_vertex(@v)
      end
      
      it "should return true if vertex is valid for path creation" do
        @graph.add_direct_path(@u, @vertex)
        @u.valid?(2).should be_true
      end
      
      it "should return false if vertex is not valid for path creation" do
        @graph.add_direct_path(@u, @vertex)
        @graph.add_direct_path(@u, @v)
        @u.valid?(2).should be_false
      end
    end
    
    describe "path weight" do
      before :each do
        @graph.add_vertex(@vertex)
        @u = Vertex.new
        @graph.add_vertex(@u)
      end
      
      it "should return path weight between vertices" do
        @graph.add_direct_path(@u, @vertex)
        @graph.add_direct_path(@vertex, @u, 5)
        @graph.path_weight(@vertex, @u).should == 5
        @graph.path_weight(@u, @vertex).should == 1
      end
      
      it "should be changed after 'change_weight' command" do
        @graph.add_direct_path(@vertex, @u, 5)
        expect{
          @graph.change_weight(@vertex, @u, 13)
        }.to change{@graph.path_weight(@vertex, @u)}.from(5).to(13)
      end
      
    end
    
    describe "vertex number" do
      before :each do
        @graph.add_vertex(@vertex)
      end

      it "should return vertex'es number" do
        @vertex.name.should == 0
      end
      
      it "should be identified by its number" do
        @graph.vertices[@vertex.name].should == @vertex
      end
      
      it "should change vertex'es number" do
        expect{
          @graph.change_vertex_number(@vertex, 2)
        }.to change{@vertex.name}.from(0).to(2)
      end
      
      it "should change vertex'es number" do
        expect{
          @graph.change_vertex_number(0, 2)
        }.to change{@vertex.name}.from(0).to(2)
      end
      
      it "should keep neighbours after changing vertex'es number" do
        u = Vertex.new
        @graph.add_vertex(u)
        @graph.add_direct_path(@vertex, u)
        @graph.add_direct_path(u, @vertex)
        expect{
          @graph.change_vertex_number(0, 2)
        }.to_not change{@graph.neighbours?(@vertex, u)}
        expect{
          @graph.change_vertex_number(2, 5)
        }.to_not change{@graph.neighbours?(u, @vertex)}
      end
      
      it "should be identifyable by its new number" do
        @graph.change_vertex_number(@vertex, 2)
        @graph.vertices[@vertex.name].should == @vertex
        @graph.vertices[2].should == @vertex
      end
      
      it "should not change into a number which is already used" do
        u = Vertex.new
        @graph.add_vertex(u)
        expect{
          @graph.change_vertex_number(0, 1)
        }.to_not change{@vertex.name}
      end
    end
    
    describe "global numbering" do
      it "should be 0 after create" do
        @graph.current_last.should == 0 
      end
      
      it "should increase after adding vertexes" do
        5.times { @graph.add_vertex(@vertex) }
        @graph.current_last.should == 5
      end
      
      it "should be the next number after last used number" do
        @graph.add_vertex(@vertex)
        @graph.current_last.should == 1
        @graph.change_vertex_number(0, 2)
        @graph.current_last.should == 3
      end
    end
    
    describe "neighbours" do
      it "should find if two vertices aren't neighbours" do
        u= Vertex.new
        v= Vertex.new
        @graph.add_vertex([u, v])
        @graph.neighbours?(u, v).should be_false
      end
      
      it "should find if two vertices are neighbours" do
        @graph.add_vertex(@vertex)
        u= Vertex.new
        @graph.add_vertex(u)
        @graph.add_direct_path(@vertex, u)
        @graph.neighbours?(@vertex, u).should be_true
      end
      
      describe "adding direct path" do
        before :each do
          @graph.add_vertex(@vertex)
          @u = Vertex.new
          @graph.add_vertex(@u)
        end
        
        it "should add a vertex as a neighbour when a direct path is created" do
          @graph.add_direct_path(0, 1)
          @graph.neighbours?(0, 1).should be_true
          @graph.neighbours?(1, 0).should be_false
        end
        
        it "should add a vertex as a neighbour when a direct path is created" do
          @graph.add_direct_path(@vertex, @u)
          @graph.neighbours?(0, 1).should be_true
          @graph.neighbours?(@u, @vertex).should be_false
        end
        
        it "should add a vertex as a neighbour when a direct path is created" do
          @graph.add_direct_path(0, 1)
          @graph.neighbours?(@vertex, @u).should be_true
          @graph.neighbours?(@u, 0).should be_false
        end
        
        it "should add a vertex as a neighbour when a direct path is created" do
          @graph.add_direct_path(@vertex, @u)
          @graph.neighbours?(@vertex, @u).should be_true
          @graph.neighbours?(0, @vertex).should be_false
        end

        it "should increase neighbour count" do
          expect{
          @graph.add_direct_path(@vertex, @u)
          }.to change{ @vertex.neighbour_count }.by(1)
        end
              
        it "should remove a vertex from neighbours when a direct path is deleted" do
          @graph.add_direct_path(@vertex, @u)
          @graph.delete_direct_path(@vertex, @u)
          @graph.neighbours?(@vertex, @u).should be_false
          @graph.neighbours?(@u, @vertex).should be_false
        end
        
        it "should decrease neighbour count when a direct path is deleted" do
          @graph.add_direct_path(@vertex, @u)
          expect{
          @graph.delete_direct_path(@vertex, @u)
          }.to change{ @vertex.neighbour_count }.by(-1)
        end
      end
    end

    describe "random graph" do
      it "should have a predefined number of vertices" do
        @r_graph = Graph.random 5, 1, 2
        @r_graph.vertice_count.should == 5
      end
      
      describe "standart random graph" do
        before :each do
          @r_graph = Graph.random 10, 2, 5
        end
        
        it "should not have more neighbours than allowed maximum number" do
          @r_graph.vertices.each do |vertex|
            vertex.neighbour_count.should <= 5
          end
        end
        
        it "should not have less neighbours than allowed minimum number" do
          @r_graph.vertices.each do |vertex|
            vertex.neighbour_count.should >= 2
          end
        end
      end
        
      describe "huge random graph" do
        it "should not take ages to create a huge random graph" do
          expect do
            Graph.random 2000, 2, 4
          end.to take_less_than(1.2).seconds
        end
        
        it "should not take ages to walk trough a huge random graph" do
            @g = Graph.random 2000, 2, 4
            expect do
              @g.jungus?
            end.to take_less_than(0.5).seconds
            #~ pending
        end
      end
      
    end
  end
  
  describe "non-oriented graph" do
    before :each do
      @graph = Graph.new 0, false
      @u = Vertex.new
      @v = Vertex.new
      @vertex = Vertex.new
      @graph.add_vertex([@u, @v])
    end
    
    it "should create two oriented paths when creating non-oriented path" do
      @graph.add_direct_path(@u, @v)
      @graph.neighbours?(@u, @v).should be_true
      @graph.neighbours?(@v, @u).should be_true
    end
    
    it "should delete two oriented paths when deleting non-oriented path" do
      @graph.add_direct_path(@u, @v)      
      @graph.delete_direct_path(@u, @v)
      @graph.neighbours?(@u, @v).should be_false
      @graph.neighbours?(@v, @u).should be_false
    end
    
    describe "random graph" do
      describe "standart random graph" do
        before :each do
          @r_graph = Graph.random 10, 2, 5, false
        end
        
        it "should not have more neighbours than allowed maximum number" do
          @r_graph.vertices.each do |vertex|
            vertex.neighbour_count.should <= 5
          end
        end
         
        it "should not have less neighbours than allowed minimum number" do
          @r_graph.vertices.each do |vertex|
            vertex.neighbour_count.should >= 2
          end
        end
      end
    end
    
    describe "vertex validation" do
      before :each do
        @graph.add_vertex(@vertex)
        @graph.add_vertex(@u)
        @graph.add_vertex(@v)
      end
      
      it "should return true if vertex is valid for path creation" do
        @graph.add_direct_path(@u, @vertex)
        @u.valid?(2).should be_true
        @vertex.valid?(2).should be_true
      end
      
      it "should return false if vertex is not valid for path creation" do
        @graph.add_direct_path(@u, @vertex)
        @graph.add_direct_path(@u, @v)
        @u.valid?(2).should be_false
        @vertex.valid?(2).should be_true
        @v.valid?(2).should be_true
      end
    end
  end
  
  describe "vertex meta" do
    before :each do
      @v = Vertex.new
    end
    
    it "should catch non-existing assingments as options" do
      expect{
        @v.my_option = 'meta'
      }.to change {@v.options[:my_option]}.from(nil).to('meta')
    end
    
    it "should catch non-existing methods as options requests" do
      expect{
        @v.my_option = 'meta'
      }.to change {@v.my_option}.from(nil).to('meta')
    end
  end
  
  describe "depth-first search" do
    describe "non-oriented graph" do
      before :each do
        @graph = Graph.new 7, false
        @graph.add_direct_path(0, 1)
        @graph.add_direct_path(0, 2)
        @graph.add_direct_path(1, 4)
        @graph.add_direct_path(2, 3)
        @graph.add_direct_path(3, 4)
        @graph.add_direct_path(3, 5)
        @graph.add_direct_path(3, 6)
        @graph.add_direct_path(5, 6)
      end
      
      it "should be 'jungus'" do
        @graph.jungus?.should be_true
      end
      
      it "should not  be 'jungus'" do
        @graph.delete_direct_path(5, 6)
        @graph.delete_direct_path(3, 6)
        @graph.jungus?.should be_false
      end
      
      it "should print the path" do
        @graph.dfs_path.should == "0 -> 1 -> 4 -> 3 -> 2 -> 5 -> 6"
      end
      
    end
  end
  
  describe "Dijkstra" do
    it "should find shortest path between 2 vertices" do
      @graph = Graph.random 2, 1, 1, false
      @graph.dijkstra @graph.vertices.first
      @graph.vertices.first.distance.should == 0
      @graph.vertices[1].distance.should == 1
    end
    
    it "should find shortest path between N vertices" do
      @graph = Graph.new 6, false
      @graph.add_direct_path(0, 1, 5)
      @graph.add_direct_path(0, 2, 10)
      @graph.add_direct_path(1, 3, 2)
      @graph.add_direct_path(2, 3, 25)
      @graph.add_direct_path(2, 5, 4)
      @graph.add_direct_path(3, 4, 10)
      @graph.add_direct_path(4, 5, 1)
      @graph.dijkstra @graph.vertices[0]
      @graph.vertices.first.distance.should == 0
      @graph.vertices[1].distance.should == 5
      @graph.vertices[2].distance.should == 10
      @graph.vertices[3].distance.should == 7
      @graph.vertices[4].distance.should == 15
      @graph.vertices[5].distance.should == 14
    end
    
  end
  
  describe "refactored" do
    it "should create vertices properly" do
      @graph= Graph.new 1000, false
      @graph.vertices.count.should == 1000
      @graph_oriented= Graph.new 1000
      @graph_oriented.vertices.count.should == 1000
    end
    
    it "should create vertices very fast" do
      expect do
        Graph.new 1000000, false
      end.to take_less_than(1).seconds
    end
  end
  it "test" do
  @vv = []
  @vv.fill(0...50000) {|i| i}
  @c= []
         expect do
            1000000.times { @c << @vv.sample(1)}
          end.to take_less_than(2).seconds
    #~ p @c.uniq.count
  end
  
end
