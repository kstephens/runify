require 'runify/pattern'

module Runify
  class Pattern
    class P
      def self.activate!
        Kernel.send(:include, Runify::Pattern::P::Helper)
        # pp Kernel.instance_methods.sort
        # raise unless Kernel.respond_to?(:rup)
      end

      def initialize pattern
        @pattern = pattern
      end

      def === data
        @p ||= Pattern.new
        Thread.current[:'Runify::Pattern::P.result'] = result = @p.match?(data, @pattern)
        result && result.match?
      end

      module Helper
        
        def rup pattern, once = false
          if once
            key = caller(0).first
            po = @@cache[key] ||= P.new(pattern)
          else
            po = P.new(pattern)
          end
          po
        end
        
        def ruv name
          Variable[name]
        end

        def rum
          Thread.current[:'Runify::Pattern::P.result']
        end
      end # module
    end # class
  end # class
end # module



