# your project process may use rkgen for class generation :
# require_relative "ast_riko_rkgen"

module Riko

  class AstNode
    def accept(visitor, arg=nil)
       name = self.class.name.split(/::/).last
       visitor.send("visit#{name}".to_sym, self ,arg) # Metaprograming !
    end

    def str
      ppr=PrettyPrinter.new
      self.accept(ppr)
    end
  end

  class Root < AstNode
    attr_accessor :elements
    def initialize elements=[]
      @elements=elements
    end

    def <<(e)
      @elements << e
    end
  end

  class Ident < AstNode
    attr_accessor :token
    def initialize token=nil
      @token=token
    end
  end

  class Io < AstNode
    attr_accessor :type,:name
    def initialize type,name
      @type,@name=type,name
    end
  end

  class Input < Io

  end

  class Output < Io
  end

  #========================================
  class Type < AstNode
  end

  class Float < Type
  end

  class Integer < Type
  end

  #========================================
  class Expression
  end

  class Binary < Expression
    attr_accessor :lhs,:op,:rhs
    def initialize lhs=nil,op=nil,rhs=nil
      @lhs,@op,@rhs=lhs,op,rhs
    end
  end

  # term
  class Int < AstNode
    attr_accessor :tok
    def initialize tok
      @tok=tok
    end
  end

  class FunCall < AstNode
    attr_accessor :name,:args
    def initialize name=nil,args=[]
      @name,@args=name,args
    end
  end

  #
  class Constraint < AstNode
    attr_accessor :label,:lhs,:rhs
    def initialize label,lhs,rhs
      @label,@lhs,@rhs=label,lhs,rhs
    end
  end

end
