require 'graph'
require 'benchmark'

describe "performance" do
  it "should be awesome for Vertex creation" do
    time = Benchmark.realtime do
      1000000.times.collect{ Vertex.new }
    end
    (time).should < 0.9
  end
  
  it "should be decent at adding vertexes to Graph" do
    #~ vertices = 5000.times.collect{ Vertex.new }
    time = Benchmark.realtime do
      @g = Graph.new 100000, 1, 4, false
    end
    (time).should < 2
    #~ puts @g.vertices
    #~ puts @g.vertices[0]
    #~ puts @g.vertices[1]
  end
end
