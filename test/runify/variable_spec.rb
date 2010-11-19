require 'runify/pattern'
# gem 'ruby-debug'; require 'ruby-debug'

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

  it "should handle variable condition matching." do
    x = v.new(:x) { | d | d.nil? }
    pm.match?(nil, x).to_ary.should == [ true, { x => nil } ]

    x = v.new(:x) { | d | d }
    # debugger
    pm.match?(nil, x).should == false
    pm.match?(true, x).to_ary.should == [ true, { x => true } ]

    x = v.new(:x) { | d | d > 1 }
    pm.match?(1, x).should == false
    pm.match?(2, x).to_ary.should == [ true, { x => 2 } ]

    pm.match?([ 2, 2 ], [ x, x ]).to_ary.should == [ true, { x => 2 } ]

    lambda { pm.match?([ 1, 0 ], x) }.should raise_error(NoMethodError)
    x = v.new(:x) { | d | Numeric === d && d > 1 }
    pm.match?([ 1, 0 ], x).should == false
  end

end

