$LOAD_PATH << '.'
require 'vertex.rb'
require 'student_group.rb'

class Subject
  attr_reader :teacher, :discipline

  def initialize(teacher, discipline)
    @teacher = teacher
    @discipline = discipline
  end

  def self.generate_vertices(subject, student_groups)
    student_groups.collect do |stud_group|
      Vertex.new(:real_name => "#{subject.name}_#{stud_group}",
                 :teacher => subject.teacher,
                 :discipline => subject.discipline,
                 :student_group => stud_group)
    end
  end

  def name
    "#{@discipline}_#{@teacher}"
  end

end
