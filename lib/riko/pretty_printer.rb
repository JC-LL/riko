require_relative 'code'

module Riko

  class PrettyPrinter

    def print ast
      ast.accept(self)
    end

    def visitRoot root,args=nil
      code=Code.new
      code << "--automatically generated"
      root.list.each{|e| code << e.accept(self)}
      code
    end

    def visitComment comment,args=nil
      code=Code.new
      comment.list.each{|e| code << e.accept(self)}
      code
    end

    def visitIdent id,args=nil
      id.token.val
    end

    def visitRoot root,args=nil
      root.elements.each{|e| e.accept(self)}
    end

    def visitInput input,args=nil
    end
  end
end
