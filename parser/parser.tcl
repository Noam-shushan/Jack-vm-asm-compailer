
source "helper_func.tcl"
source "program_structure.tcl"

# each token is a dict with the following keys:
#   label: the token type
#   token: the token value
# for example: { label: "symbol", token: "}" }
# or { label: "identifier", token: "foo" }
# 
# the jack grammer is as follows:

# Lexical Elements:
# keyword -> "class" | "constructor" | "function" | "method" | "field" | "static" | "var" | "int" | "char" | "boolean" | "void" | "true" | "false" | "null" | "this" | "let" | "do" | "if" | "else" | "while" | "return"
# symbol -> "{" | "}" | "(" | ")" | "[" | "]" | "." | "," | ";" | "+" | "-" | "*" | "/" | "&amp;" | "|" | "&lt;" | "&gt;" | "=" | "~"
# integerConstant -> 0 | [1-9][0-9]*
# stringConstant -> "..." (any sequence of unicode characters except double quote and newline)
# identifier -> (letter|"_") (letter | digit | "_")*

# Statements:
# statement -> letStatement | ifStatement | whileStatement | doStatement | returnStatement
# statements -> statement*
# ifStatement -> "if" "(" expression ")" "{" statements "}" ("else" "{" statements "}")?
# whileStatement -> "while" "(" expression ")" "{" statements "}"
# letStatement -> "let" varName ("[" expression "]")? "=" expression ";"
# doStatement -> "do" subroutineCall ";"
# returnStatement -> "return" expression? ";"

# Expression:
# expression -> term (op term)*
# term -> integerConstant | stringConstant | keywordConstant | varName | varName "[" expression "]" | subroutineCall | "(" expression ")" | unaryOp term
# subroutineCall -> subroutineName "(" expressionList ")" | (className | varName) "." subroutineName "(" expressionList ")"
# expressionList -> (expression ("," expression)* )?
# keywordConstant -> "true" | "false" | "null" | "this"
# op -> "+" | "-" | "*" | "/" | "&amp;" | "|" | "&lt;" | "&gt;" | "="
# unaryOp -> "-" | "~"

# Program Structure:
# class -> "class" className "{" classVarDec* subroutineDec* "}"
# classVarDec -> ("static" | "field") type varName ("," varName)* ";"
# subroutineDec -> ("constructor" | "function" | "method") ("void" | type) subroutineName "(" parameterList ")" subroutineBody
# parameterList -> (type varName ("," type varName)*)?
# subroutineBody -> "{" varDec* statements "}"
# varDec -> "var" type varName ("," varName)* ";"
# type -> "int" | "void" | "boolean" | className
# className -> identifier
# subroutineName -> identifier
# varName -> identifier

proc complie { tokens } {
    set result [complie_class tokens]
    puts $result
    return $result
}
