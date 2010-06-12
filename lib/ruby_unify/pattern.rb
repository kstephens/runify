module RubyUnify
  module Pattern
    def match?(data, pattern, result = nil)
      result ||= Result.new
      _match?(data, pattern, result)
      result = result.match? && result
      $stderr.puts "  match(#{data.inspect}, #{pattern.inspect}) => #{result.inspect}"
      result
    end

    def _match?(data, pattern, result)
      return unless result.match?

      case pattern
      when Variable
        if result.has?(pattern)
          x = result.get(pattern)
          unless _equal?(data, x)
            return result.no_match!
          end
        else
          result.capture!(pattern, data)
        end
      else
        return result if data.object_id == pattern.object_id

        unless data.class == pattern.class
          return result.no_match!
        end

        case data
        when Array
          unless data.size == pattern.size
            return result.no_match!
          end
          data.each_with_index do | x, i |
            return unless _match?(x, pattern[i], result)
          end
        else
          unless data == pattern
            return result.no_match!
          end
        end
      end

      result
    end

    def _equal?(x, y)
      return true if x.object_id == y.object_id
      x.class == y.class and
        case x
        when Array
          return false unless x.size == y.size
          x.each_with_index do | a, i | 
            return false unless _equal?(a, y[i])
          end
          true
        else
          x == y
        end
    end

    extend self

    class Variable
      def initialize n, inspect = nil
        @name = n
        @inspect = inspect && inspect.freeze
      end

      @@instances = { }

      def self.[](n)
        n = n.to_sym
        @@instances[n] ||=
          new(n, "#{self.name}[#{n.inspect}]")
      end

      def inspect
        @inspect || super
      end
    end

    class Result
      def initialize h = nil, insp = nil
        @h = h || { }
        @match = true
      end

      def match?
        @match
      end

      def no_match!
        @match = false
      end

      def has? x
        @h.key?(x)
      end

      def capture! x, y
        $stderr.puts "    capture! #{x.inspect} => #{y.inspect}"
        @h[x] = y
        self
      end

      def get x
        @h[x]
      end

      def variables
        @h.keys
      end

      def to_hash
        @h
      end
    end
  end

  module Unify
    def match_and_unify data, pattern, transform, result = nil
      result = Pattern.match?(data, pattern)
      if result
        result = [ true, unify(transform, result) ]
      else
        result = [ false, data ]
      end
      $stderr.puts "  match_and_unify(#{data.inspect}, #{pattern.inspect}, #{transform.inspect}) => #{result.inspect}"
      result
    end

    def unify input, result
      case input
      when Array
        input.map { | x | unify(x, result) }
      else
        if result.has?(input)
          result.get(input)
        else
          input
        end
      end
    end

    extend self
  end

end


if false

pm = RubyUnify::Pattern
ru = RubyUnify::Unify
v = RubyUnify::Pattern::Variable

pm.match?(nil, nil)
pm.match?(1, 1)
pm.match?(1, 2)
pm.match?([ ], [ ])
pm.match?([ ], nil)
pm.match?(nil, [ ])
pm.match?([ 1 ], [ 1 ])
pm.match?([ 1 ], [ 2 ])
pm.match?([ 1, 2 ], [ 1 ])
pm.match?([ 1 ],    [ 1, 2 ])

pm.match?(nil, v[:x])
pm.match?(1, v[:x])
pm.match?(v[:x], v[:x])

pm.match?([ 1, 2 ], v[:x])
pm.match?([ 1, 1 ], [ v[:x], 1 ])
pm.match?([ 1, 1 ], [ 1, v[:x] ])
pm.match?([ 1, 1 ], [ 1, v[:x] ])
pm.match?([ 1, 1 ], [ v[:x], v[:x] ])
pm.match?([ 1, 2 ], [ v[:x], v[:x] ])

ru.match_and_unify(1, v[:x], [ 2, v[:x]])

end
