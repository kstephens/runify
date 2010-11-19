require 'runify/ruby_parse'

describe "Runify::RubyParse" do
  attr_accessor :rp, :v

  before(:each) do 
    self.rp = Runify::RubyParse.new
    self.v = Runify::Pattern::Variable
  end

  it "should handle ruby syntax pattern matching." do
    rp.match?("x", "x").to_ary.should == [ true, { } ]
    rp.match?("x", "y").should == false
  end

  it "should handle ruby syntax with variables." do
    rp.match?("x", "y._?").to_ary.should == [ true, { v[:y] => [ :vcall, :x ] } ]
    rp.match?("x + x", "y._? + y._?").to_ary.should == [ true, { v[:y] => [ :vcall, :x ] } ]
    rp.match?("x + y", "y._? + y._?").should == false
    rp.match?("x += 1", "x._?").to_ary.should == [true, { v[:x] => [:lasgn, :x, [:call, [:lvar, :x], :+, [:array, [:lit, 1]]]]}]
    # BUG!!!
    rp.match?("def foo(x, y); bar; baz; end", "def foo(x = :_?, y = :_?); body._?; end").should == false  
  end

  it "should handle ruby pattern unification." do    
    rp.match_and_unify("x + x", "x._? + x._?", "x._? * 2").should == [true, [:call, [:vcall, :x], :*, [:array, [:lit, 2]]]]
  end

end

