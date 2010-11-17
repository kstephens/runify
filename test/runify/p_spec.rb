require 'ruby_unify/pattern/p'

describe "RubyUnify::Pattern::P" do
  before(:all) do 
    RubyUnify::Pattern::P.activate!
  end

  after(:all) do
  end
  
  it "should handle p in case when statements." do
    case nil
    when p(nil)
      r = :nil
    else
      r =:else
    end
    r.should == :nil
    
    case :x
    when p(nil)
      r = :nil
    else
      r = :else
    end
    r.should == :else
    
    case :x
    when p(:x)
      r = :x
    else
      r = :else
    end
    r.should == :x
    
    case [ :x, :y ]
    when p(nil)
      r = :nil
    when p(5)
      r = 5
    when p([ :x, :y ])
      r = :x_y
    else
      r = :else
    end
    r.should == :x_y
  end

  it "should handle basic variable matching." do
    case 5
    when p(v(:x))
      m.class.should == RubyUnify::Pattern::Result
      r = m[:x]
    else
      r = :else
    end
    r.should == 5

    case [ :x, :y ]
    when p([ v(:x), :y ])
      m.class.should == RubyUnify::Pattern::Result
      r = m[:x]
    else
      r = :else
    end
    r.should == :x

  end
  
  it "should handle basic pattern unification." do    
  end
  
end # describe

