require 'ruby_unify/pattern'

describe "RubyUnify::Pattern" do
  attr_accessor :pm, :ru, :v

  before(:each) do 
    self.pm = RubyUnify::Pattern.new
    self.ru = RubyUnify::Unify.new
    self.v = RubyUnify::Pattern::Variable
 end

  it "should handle atomic pattern matching." do
    pm.match?(nil, nil).to_ary.first.should == true
    pm.match?(true, true).to_ary.first.should == true
    pm.match?(false, nil).should == false
    pm.match?(1, 1).to_ary.first.should == true
    pm.match?(1, 2).should == false
    pm.match?(:x, :x).to_ary.first.should == true
    pm.match?(:x, :y).should == false
    pm.match?(:x, 1).should == false
    pm.match?("x", "x").to_ary.first.should == true
    pm.match?("x", "y").should == false
    pm.match?("x", :y).should == false
  end

  it "should handle Array pattern matching." do  
    pm.match?([ ], [ ]).to_ary.first.should == true
    pm.match?([ ], nil).should == false
    pm.match?(nil, [ ]).should == false
    pm.match?([ 1 ], [ 1 ]).to_ary.first.should == true
    pm.match?([ 1 ], [ 2 ]).should == false
    pm.match?([ 1, 2 ], [ 1 ]).should == false
    pm.match?([ 1 ],    [ 1, 2 ]).should == false
  end

  it "should handle Hash pattern matching." do  
    pm.match?({ }, { }).to_ary.first.should == true
    pm.match?({ }, nil).should == false
    pm.match?(nil, { }).should == false
    pm.match?({ :a => 1 }, { :a => 1 }).to_ary.first.should == true
    pm.match?({ :a => 1 }, [ :a, :b ]).should == false
    pm.match?({ :a => 1 }, { :a => 1, :b => 2 }).should == false
    pm.match?({ :a => 1 }, { :a => 1, :b => 2 }).should == false
    pm.match?({ :b => 2, :a => 1 }, { :a => 1, :b => 2 }).to_ary.first.should == true
  end

  it "should handle basic variable matching." do
    pm.match?(nil, v[:x]).to_ary.should == [ true, { v[:x] => nil } ]
    pm.match?(1, v[:x]).to_ary.should == [ true, { v[:x] => 1 } ]
    pm.match?(v[:x], v[:x]).to_ary.should == [ true, { v[:x] => v[:x] } ]

    pm.match?(a = [ 1, 2 ], v[:x]).to_ary.should == [ true, { v[:x] => a } ]
    pm.match?([ 1, 1 ], [ v[:x], 1 ]).to_ary.should == [ true, { v[:x] => 1 } ]
    pm.match?([ 1, 2 ], [ 1, v[:x] ]).to_ary.should == [ true, { v[:x] => 2 } ]
    pm.match?([ 1, 1 ], [ v[:x], v[:x] ]).to_ary.should == [ true, { v[:x] => 1 } ]
    pm.match?([ 1, 2 ], [ v[:x], v[:x] ]).should == false
  end

  it "should handle direct or indirect variable binding lookups." do
    m = pm.match?(5, v[:x])
    m.should_not == nil
    m[v[:x]].should == 5
    m[:x].should == 5
  end

  it "should handle basic pattern unification." do    
    ru.match_and_unify(1, v[:x], [ 2, v[:x]]).to_ary.should == [ true, [ 2, 1 ] ]
    ru.match_and_unify([ 1, 2 ], [ v[:x], v[:x] ], [ 2, v[:x]]).to_ary.should == [ false, [ 1, 2 ] ]
    ru.match_and_unify([ 1, 2 ], [ v[:x], v[:y] ], { v[:x] => v[:y], :b => 2 }).to_ary.should == [true, {1=>2, :b=>2}]
  end

end

