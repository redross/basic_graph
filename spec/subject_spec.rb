require 'subject'

describe "Subject" do
  describe "generating vertices" do
    before do
      @student_groups = ['R1', 'R2', 'H1']
      @subject = Subject.new('Greg Pollack', 'Ruby on Rails with zombies')
    end

    it "should generate some vertices" do
      vertices = Subject.generate_vertices(@subject, @student_groups)
      vertices.size.should == 3
      vertex = vertices.first
      vertex.is_a?(Vertex).should be_true
      vertex.real_name.should == @subject.name.to_s + "_R1"
      vertex.teacher.should == 'Greg Pollack'
      vertex.discipline.should == 'Ruby on Rails with zombies'
    end

  end

end
