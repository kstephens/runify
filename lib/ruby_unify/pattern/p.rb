require 'ruby_unify/pattern'

module RubyUnify
  class Pattern
    class P
      def self.activate!
        Kernel.send(:include, Helper)
      end

      def initialize pattern
        @pattern = pattern
      end

      def === data
        @p ||= Pattern.new
        Thread.current[:'RubyUnify::Pattern::P.result'] = result = @p.match?(data, @pattern)
        result.match?
      end

      module Helper
        
        def p pattern, once = false
          if once
            key = caller(0).first
            po = @@cache[key] ||= P.new(pattern)
          else
            po = P.new(pattern)
          end
          po
        end
        
        def v name
          Variable[name]
        end

        def m
          Thread.current[:'RubyUnify::Pattern::P.result']
        end
      end # module
    end # class
  end # class
end # module



