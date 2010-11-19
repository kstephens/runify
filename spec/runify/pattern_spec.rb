require 'runify/pattern'

describe "Runify::Pattern" do
  attr_accessor :pm

  before(:each) do 
    self.pm = Runify::Pattern.new
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

end

