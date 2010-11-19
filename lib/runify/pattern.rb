module Runify
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
        return result.no_match! unless pattern.match?(data)
        if result.key?(pattern)
          x = result[pattern]
          unless _equal?(data, x)
            return result.no_match!
          end
        else
          result.capture!(pattern, data)
          # FALL THROUGH
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


    class Condition
      def initialize n, inspect = nil, &block
        @name = n
        @inspect = inspect && inspect.freeze
        @condition = block_given? && block
      end

      def match? value
        @condition ? @condition.call(value) : true
      end
    end


    class Variable < Condition
      @@instances = { }

      def self.[](n)
        n = n.to_sym
        raise ArgumentError, "block given" if block_given?
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

end

