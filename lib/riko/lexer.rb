require_relative 'generic_lexer'
require_relative 'generic_parser'

module Riko

  class Lexer < GenericLexer
    def initialize
      super

      keyword 'begin'
      keyword 'end'
      keyword 'input'
      keyword 'output'
      keyword 'interval'
      keyword 'scalar'
      keyword 'float'
      keyword 'integer'
      keyword 'constraint'
      keyword 'abs'

      #.............................................................
      token :comment           => /\A\/\/(.*)$/
      token :ident             => /[a-zA-Z]\w*/
      token :string_literal    => /"[^"]*"/
      token :char_literal      => /'(\w+)'/
      token :int_literal       => /\d+/

      token :comma             => /\A\,/
      token :colon             => /\A\:/
      token :semicolon         => /\A\;/
      token :lparen            => /\A\(/
      token :rparen            => /\A\)/

      # arith
      token :add               => /\A\+/
      token :sub               => /\A\-/
      token :mul               => /\A\*/
      token :div               => /\A\//

      token :imply             => /\A\=\>/

      # logical
      token :eq                => /\A\=/
      token :neq               => /\A\/\=/
      token :gte               => /\A\>\=/
      token :gt                => /\A\>/
      token :leq               => /\A\<\=/
      token :lt                => /\A\</

      token :ampersand         => /\A\&/

      token :dot               => /\A\./
      token :bar               => /\|/
      #............................................................
      token :newline           =>  /[\n]/
      token :space             => /[ \t\r]+/

    end #def
  end #class
end #module
