# gem 'ruby-debug'; require 'ruby-debug'

require 'runify/pattern/p'

describe "Runify::Pattern::P" do
  before(:each) do
    extend Runify::Pattern::P::Helper
  end

  it "should handle p(...) === data expressions." do
    (rup(nil) === nil).should == true
    (rup(nil) === :x).should == false
    (rup(:x) === false).should == false
    (rup(:x) === :x).should == true

    (rup(nil) === [ :x, :y ]).should == false
    (rup(:x) === [ :x, :y ]).should == false
    (rup(5) === [ :x, :y ]).should == false
    (rup([ :x ]) === [ :x, :y ]).should == false
    (rup([ :x, :y ]) === [ :x, :y ]).should == true
  end

  it "should handle basic variable matching." do
    (rup(ruv(:x)) === 5).should == true
    rum.class.should == Runify::Pattern::Result
    rum[:x].should == 5

    (rup([ ruv(:x), :b ]) === [ :a, :b ]).should == true 
    rum.class.should == Runify::Pattern::Result
    rum[:x].should == :a
  end
  
  it "should handle basic pattern unification." do    
  end
  
end # describe

