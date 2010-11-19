require 'runify/pattern'

module Runify
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
        o = input.dup
        o.map! { | x | unify(x, result) }
        o
      when Hash
        hash = input.dup
        hash.clear
        input.each do | k, v | 
          hash[unify(k, result)] = unify(v, result)
        end
        hash
      else
        unify_other input, result
      end
    end

    def unify_other input, result
      if result.key?(input)
        result[input]
      else
        input
      end
    end

  end

end


