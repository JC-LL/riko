# coding: utf-8
require_relative 'generic_parser'
require_relative 'ast'
require_relative 'lexer'

module Riko

  class Parser < GenericParser

    attr_accessor :options
    attr_accessor :lexer,:tokens
    attr_accessor :basename,:filename

    def initialize options={}
      @options=options
    end

    def lex filename
      unless File.exists?(filename)
        raise "ERROR : cannot find file '#{filename}'"
      end
      begin
        str=IO.read(filename).downcase
        tokens=Lexer.new.tokenize(str)
        tokens=tokens.select{|t| t.class==Token} # filters [nil,nil,nil]
        tokens.reject!{|tok| tok.is_a? [:comment,:newline,:space]}
        return tokens
      rescue Exception=>e
        unless options[:mute]
          puts e.backtrace
          puts e
        end
        raise "an error occured during LEXICAL analysis. Sorry. Aborting."
      end
    end

    def parse filename
      begin
        @tokens=lex(filename)
        puts "......empty file !" if tokens.size==0
        @tokens=@tokens.reject{|tok| tok.kind==:comment}
        root=parse_root()
      rescue Exception => e
        unless options[:mute]
          puts e.backtrace
          puts e
        end
        raise
      end
      root
    end

    def parse_root
      root=Root.new
      root << parse_inputs
      root << parse_outputs
      root << parse_constraints
      root
    end

    def parse_inputs
      inputs=[]
      expect :begin
      expect :input
      while showNext.kind!=:end
        inputs << parse_input
      end
      expect :end
      expect :input
      expect :semicolon
      inputs
    end

    def parse_input
      if showNext.is_a? [:interval,:scalar]
        constraint_type=acceptIt
        ident=Ident.new(expect :ident)
        expect :lparen
        type=parse_type
        expect :rparen
        expect :semicolon
        return Input.new(ident,type)
      else
        raise "#{showNext.pos} expecting 'interval' or 'scalar'. Got '#{showNext.val}'"
      end
    end

    def parse_type
      if showNext.is_a? [:float,:integer]
        tok=acceptIt
        case tok.kind
        when :float
          return Riko::Float.new
        when :integer
          return Riko::Integer.new
        end
      else
        raise "line #{showNext.pos}. Expecting 'float' or 'integer'"
      end
    end

    def parse_outputs
      outputs=[]
      expect :begin
      expect :output
      while showNext.kind!=:end
        outputs << parse_output
      end
      expect :end
      expect :output
      expect :semicolon
      outputs
    end

    def parse_output
      if showNext.is_a? [:interval,:scalar]
        constraint_type=acceptIt
        expect :ident
        expect :lparen
        parse_type
        expect :rparen
        expect :semicolon
      else
        raise "#{showNext.pos} expecting 'interval' or 'scalar'. Got '#{showNext.val}'"
      end
    end

    def parse_constraints
      constraints=[]
      expect :begin
      expect :constraint
      while showNext.kind!=:end
        constraints << parse_constraint
      end
      expect :end
      expect :constraint
      expect :semicolon
      constraints
    end

    def parse_constraint
      if showNext.is_a? :ident
        label=Ident.new(acceptIt)
        expect :colon
        lhs=Ident.new(expect :ident)
        expect :eq
        rhs=parse_expression()
        expect :semicolon
        return Constraint.new(label,lhs,rhs)
      else
        raise "line #{showNext.pos} : expecting ident. Got '#{showNext.val}'"
      end
    end

    def parse_expression
      parse_arith
    end

    def parse_arith
      parse_add
    end

    def parse_add
      e1=parse_mult
      while showNext.is_a? [:add,:sub]
        op=acceptIt.kind
        e2=parse_mult
        e1=Binary.new(e1,op,e2)
      end
      e1
    end

    def parse_mult
      e1=parse_term
      while showNext.is_a? [:mul,:div]
        op=acceptIt.kind
        e2=parse_term
        e1=Binary.new(e1,op,e2)
      end
      e1
    end

    def parse_name
      Ident.new expect(:ident)
    end

    def parse_term
      case showNext.kind
      when :ident
        return Ident.new(acceptIt)
      when :ident
        return Ident.new(acceptIt)
      when :int_literal
        return Int.new(acceptIt)
      when :abs
        return parse_funcall()
      else
        raise "unknown term '#{showNext.val}'"
      end
    end

    def parse_funcall
      fcall=FunCall.new(nil,[])
      case showNext.kind
      when :abs
        fcall.name=Ident.new(acceptIt)
      end
      expect :lparen
      fcall.args << parse_expression
      while showNext.is_a? :comma
        acceptIt
        fcall.args << parse_expression
      end
      expect :rparen
      return fcall
    end
    # ....etc...
  end
end
