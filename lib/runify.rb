module Runify
  EMPTY_Hash = { }.freeze
  EMPTY_Array = [ ].freeze
  EMPTY_String = ''.freeze
  class Error < ::Exception; end
end

require 'runify/pattern'
# OPTIONAL
# require 'runify/ruby_parse'
