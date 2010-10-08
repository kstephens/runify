require 'ruby_unify/pattern'

gem 'ParseTree'
require 'parse_tree'

module RubyUnify
  class RubyParse
    attr_accessor :pattern, :unify

    def pattern
      @pattern ||=
        Pattern.new
    end

    def unify
      @unify ||=
        begin
          obj = Unify.new
          obj.pattern = pattern
          obj
        end
    end

    def match? data, pat, result = nil
      data = convert_parse_tree data
      pat = convert_parse_tree pat

      pattern.match?(data, pat, result)
    end

    def match_and_unify data, pat, template, result = nil
      data = convert_parse_tree data
      pat = convert_parse_tree pat
      template = convert_parse_tree template

      unify.match_and_unify(data, pat, template, result)
    end

    def convert_parse_tree expr
      expr = ::ParseTree.translate(expr) if String === expr

      return expr unless Array === expr
      case

        # x._? 
        #   =>
        # [:call, [:vcall, x], :_?]
      when expr[0] == :call &&
          Array === (e1 = expr[1]) &&
          e1[0] == :vcall &&
          expr[2] == :_?
        Pattern::Variable[e1[1]]

        # FIXME:!!!
        #
        # def f(x => :_?, ...)
        #   =>
        # [:defn, :foo, [:scope, [:block, [:args, x, ..., [:block, [:lasgn, x, [:lit, :_?]]] ]]]

      when expr[0] == :scope &&
          Array === (e1 = expr[1]) &&
          e1[0] == :block &&
          Array === (e11 = e1[1]) &&
          e11[0] == :args &&
          expr[2] == :_?
        Pattern::Variable[e1[1]]

      else
        expr.map{|x| convert_parse_tree(x)}
      end
    end

  end

end


