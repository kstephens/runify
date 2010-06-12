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
      if expr[0] == :call &&
          Array === (e1 = expr[1]) &&
          e1[0] == :vcall &&
          expr[2] == :_?
        Pattern::Variable[e1[1]]
      else
        expr.map{|x| convert_parse_tree(x)}
      end
    end

    extend self
  end

end


rp = RubyUnify::RubyParse

rp.match?("x", "x")
rp.match?("x", "y._?")
rp.match?("x + x", "y._? + y._?")
rp.match?("x + y", "y._? + y._?")
rp.match?("x += 1", "x._?")

rp.match_and_unify("x + x", "x._? + x._?", "x._? * 2")

