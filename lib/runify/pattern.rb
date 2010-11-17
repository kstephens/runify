module RubyUnify
  class Pattern
    def match?(data, pattern, result = nil)
      result ||= Result.new
      _match?(data, pattern, result)
      result = result.match? && result
      # $stderr.puts "  match(#{data.inspect}, #{pattern.inspect}) => #{result.inspect}" if $DEBUG
      result
    end

    def _match?(data, pattern, result)
      return unless result.match?

      case pattern
      when Variable
        if result.key?(pattern)
          x = result[pattern]
          unless _equal?(data, x)
            return result.no_match!
          end
        else
          result.capture!(pattern, data)
        end
      else
        unless data.class == pattern.class
          return result.no_match!
        end

        case data
        when Array
          return result if data.object_id == pattern.object_id
          unless data.size == pattern.size
            return result.no_match!
          end
          data.each_with_index do | x, i |
            return result.no_match! unless _match?(x, pattern[i], result)
          end
        when Hash
          return result if data.object_id == pattern.object_id
          unless data.size == pattern.size
            return result.no_match!
          end
          data.each do | xk, xv |
            if pattern.key?(xk)
              yv = pattern[xk]
              return result.no_match! unless _match?(xv, yv, result)
            end
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
      x.class == y.class and
        case x
        when Array
          return true if x.object_id == y.object_id
          return false unless x.size == y.size
          x.each_with_index do | a, i | 
            return false unless _equal?(a, y[i])
          end
          true
        when Hash
          return true if x.object_id == y.object_id
          return false unless x.size == y.size
          x.each do | xk, xv |
            if y.key?(xk)
              yv = y[xk]
              return false unless _equal?(xv, yv)
            else
              return false
            end
          end
          true
        else
          x == y
        end
    end


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

      def to_ary
        [ @match, @h ]
      end

      def match?
        @match
      end

      def no_match!
        @match = false
      end

      def key? x
        @h.key?(x)
      end

      def capture! x, y
        # $stderr.puts "    capture! #{x.inspect} => #{y.inspect}" if $DEBUG
        @h[x] = y
        self
      end

      def [](x)
        x = Variable[x] unless Variable === x
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

  class Unify
    attr_accessor :pattern

    def pattern
      @pattern ||=
        Pattern.new
    end

    def match_and_unify data, pat, transform, result = nil
      result = pattern.match?(data, pat)
      if result
        result = [ true, unify(transform, result) ]
      else
        result = [ false, data ]
      end
      # $stderr.puts "  match_and_unify(#{data.inspect}, #{pat.inspect}, #{transform.inspect}) => #{result.inspect}" if $DEBUG
      result
    end

    def unify input, result
      case input
      when Array
        input.map { | x | unify(x, result) }
      when Hash
        hash = { }
        input.each do | k, v | 
          hash[unify(k, result)] = unify(v, result)
        end
        hash
      else
        if result.key?(input)
          result[input]
        else
          input
        end
      end
    end

  end

end


