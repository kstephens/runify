require 'runify/unify'

describe "Runify::Pattern" do
  attr_accessor :pm, :ru, :v

  before(:each) do 
    self.pm = Runify::Pattern.new
    self.v = Runify::Pattern::Variable
    self.ru = Runify::Unify.new
 end

  it "should handle basic pattern unification." do    
    ru.match_and_unify(1, v[:x], [ 2, v[:x]]).to_ary.should == [ true, [ 2, 1 ] ]
    ru.match_and_unify([ 1, 2 ], [ v[:x], v[:x] ], [ 2, v[:x]]).to_ary.should == [ false, [ 1, 2 ] ]
    ru.match_and_unify([ 1, 2 ], [ v[:x], v[:y] ], { v[:x] => v[:y], :b => 2 }).to_ary.should == [true, {1=>2, :b=>2}]
  end

  module Runify::Test
    class MyArray < Array
      def initialize *elems
        super()
        concat(elems)
      end

      def _0
        first
      end
    end
  end

  it "should handle pattern unification of subclasses of Array." do
    r = ru.match_and_unify(Runify::Test::MyArray.new( 1, 2 ), 
                           Runify::Test::MyArray.new(v[:x], v[:y]),
                           Runify::Test::MyArray.new(v[:x], v[:y], 3, 4))

    r = r.to_ary
    r[0].should == true
    r = r[1]
    r.class.should == Runify::Test::MyArray
    r.size.should == 4
    r[0].should == 1
    r[1].should == 2
    r[2].should == 3
    r[3].should == 4
  end

  module Runify::Test
    class MyHash < Hash
      def initialize h
        update(h)
      end
    end
  end

  it "should handle pattern unification of subclasses of Hash." do
    r = ru.match_and_unify(d = Runify::Test::MyHash.new( :a => 1, :b => 2 ), 
                           p = Runify::Test::MyHash.new( :a => v[:x], :b => v[:y]),
                           u = Runify::Test::MyHash.new( :x => v[:x], :y => v[:y], :c => 3))

    r = r.to_ary
    r[0].should == true
    r = r[1]
    r.class.should == Runify::Test::MyHash
    r.keys.sort_by{|a| a.to_s}.should == [ :c, :x, :y ]
    r[:x].should == 1
    r[:y].should == 2
    r[:c].should == 3
  end

end

