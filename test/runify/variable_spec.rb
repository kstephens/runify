require 'runify/pattern'

describe "Runify::Pattern::Variable" do
  attr_accessor :pm, :v

  before(:each) do 
    self.pm = Runify::Pattern.new
    self.v = Runify::Pattern::Variable
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

end

