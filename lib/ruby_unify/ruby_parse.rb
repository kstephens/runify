require 'ruby_unify/pattern'

gem 'ParseTree'
require 'parse_tree'

module RubyUnify
  module RubyParse
    def match? data, pattern, result = nil
      data = convert_parse_tree data
      pattern = convert_parse_tree pattern

      Pattern.match?(data, pattern, result)
    end

    def match_and_unify data, pattern, template, result = nil
      data = convert_parse_tree data
      pattern = convert_parse_tree pattern
      template = convert_parse_tree template

      Unify.match_and_unify(data, pattern, template, result)
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

    extend self
  end

end


