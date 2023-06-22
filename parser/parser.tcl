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


source "helper_func.tcl"
source "program_structure.tcl"

proc get_xml_content { file_conntent } {
    set file_content_list [split $file_conntent "\n"]
    set tokens_list [list]
    foreach line $file_content_list {
        set raw_tokens [lindex [split [string trim $line] "</"] 1]
        set label [string trim [lindex [split $raw_tokens ">"] 0]]
        set token [string trim [lindex [split $raw_tokens ">"] 1]]
        if { $line == "<symbol> / </symbol>" } {
            set lable_token_dict [dict create "label" "symbol" "token" "/"]
            lappend tokens_list $lable_token_dict
        }
        if { $label != "tokens" && $token != "" } {
            set lable_token_dict [dict create "label" $label "token" $token]
            lappend tokens_list $lable_token_dict
        }
    }
    return $tokens_list
}


proc parse_dir { dir_name } {
    set tokens_files [glob -directory $dir_name -types f -tails *T.xml]
    foreach file $tokens_files {
        # get tokens from file
        set file_xml_conntent [read_file $dir_name/$file]
        set tokens [get_xml_content $file_xml_conntent]
        set xml_tree_result [complie $tokens]
        set file_name [string range $file 0 end-5]
        write_file $dir_name/$file_name.xml $xml_tree_result
        puts "file $file_name.xml created"
    }
}

proc complie { tokens } {
    set result [complie_class tokens]
    return $result
}

