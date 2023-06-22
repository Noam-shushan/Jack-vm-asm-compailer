# Legal symbols of Jack
set symbols [list "(" ")" "\[" "\]" "\{" "\}" "," ";" "=" "."]

# Legal operators of Jack
set operators [list "+" "-" "*" "/" "&" "|" "~" "<" ">"]

# Legal reserved words of Jack
set reserved_words [list "class" "constructor" "method" "function" "int" "boolean" \
    "char" "static" "field" "let" "do" "if" "else" "while" \
    "return" "true" "false" "null" "this" "var" "void"]

# Enum like for token types in Jack:
# symbol, keyword, identifier, integerConstant, stringConstant
set KEYWORD "keyword"
set SYMBOL "symbol"
set IDENTIFIER "identifier"
set INT_CONST "integerConstant"
set STRING_CONST "stringConstant"

# This function takes in a line of Jack code and returns a list of tokens in the line.
# :param line: line of Jack code
# :return: list of tokens in line
proc parse_line_to_tokens {line} {
    global symbols
    global operators
    global reserved_words
    global KEYWORD
    global SYMBOL
    global IDENTIFIER
    global INT_CONST
    global STRING_CONST

    # regex for symbols, operators, reserved words, string, identifier, and integer constant
    set symbols_reg {[()\[\]\{\},;=\.]}
    set operators_reg {[+\-*/&|~<>]}
    set reserved_words_reg {\y(?:class|constructor|method|function|int|boolean|char|static|field|let|do|if|else|while|return|true|false|null|this|var)\y}
    set string_reg {[\"]}
    set identifier_reg {\w+}
    set int_const_reg {\d+}

    # get all tokens in line using regex
    set regex_expression "$symbols_reg|$operators_reg|$reserved_words_reg|$string_reg|$identifier_reg|$int_const_reg"
    set tokens [regexp -all -inline $regex_expression $line]

    # used to indentify if we are in a string and to store the string
    set is_in_string 0
    set string {}

    foreach token $tokens {
        if {$is_in_string} {
            #   if we are in a string, we need to check if we have reached the end of the string
            if {$token == "\""} {
                lappend result [list [join $string " "] $STRING_CONST]
                set string {}
                set is_in_string 0
            } else {
                lappend string $token
            }
        } elseif {$token == "\""} {
            #  if we are not in a string, we need to check if we have reached the start of a string
            set is_in_string 1
        } elseif {[lsearch -exact $symbols $token] != -1} {
            #  check if token is a symbol
            lappend result [list $token $SYMBOL]
        } elseif {[lsearch -exact $reserved_words $token] != -1} {
            #  check if token is a reserved word
            lappend result [list $token $KEYWORD]
        } elseif {[string is integer -strict $token]} {
            #  check if token is an integer constant
            lappend result [list $token $INT_CONST]
        } elseif {[lsearch -exact $operators $token] != -1} {
            #  check if token is an operator
            # handle XML special characters
            if {$token == "<"} {
                lappend result [list "&lt;" $SYMBOL]
            } elseif {$token == ">"} {
                lappend result [list "&gt;" $SYMBOL]
            } elseif {$token == "&"} {
                lappend result [list "&amp;" $SYMBOL]
            } else {
                lappend result [list $token $SYMBOL]
            }
        } elseif {[string is space $token]} {
            #  ignore spaces
            continue
        } else {
            #  dosen't match any of the above => identifier
            lappend result [list $token $IDENTIFIER]
        }
    }
    return $result
}

# This function takes in a token and its token type and returns an XML representation of the token.
# :param token: token value
# :param token_type: token type
# :return: xml representation of token
proc get_xml_token {token token_type} {
    return "<$token_type>$token</$token_type>"
}

# This function takes in the filename of a Jack file and generates an XML representation of the Jack file.
# :param file_name: file name of Jack file
proc tokenize_file { file_name } {
    set xml_filename [file rootname $file_name]T.xml
    puts "$xml_filename"
    set xml_file [open $xml_filename "w"]
    puts $xml_file "<tokens>"
    set jack_code [get_jack_file_lines $file_name]
    foreach line $jack_code {
        set parsed_line [parse_line_to_tokens $line]
        foreach token $parsed_line {
            lassign $token t tt
            puts $xml_file "\t[get_xml_token $t $tt]"
        }
    }
    puts $xml_file "</tokens>"
    close $xml_file
}

proc tokenize_dir { dir_name } {
    set files [glob -directory $dir_name -types f -tails *.jack]
    puts $files

    foreach file $files {
        tokenize_file $dir_name/$file
        puts "Tokenized $file"
    }
}

# This function takes in the filename of a Jack file and returns a list of code lines in the file with no comments.
# :param filename: filename of Jack file
# :return: code lines only (no comments) in file as a list
proc get_jack_file_lines {filename} {
    set start_block_token "/**"
    set end_block_token "*/"
    set jack_file [open $filename r]
    set is_in_block_comment 0
    set result {}
    while {[gets $jack_file line] >= 0} {
        # watch for block comments
        if {$is_in_block_comment} {
            if {[string first $end_block_token $line] != -1} {
                set is_in_block_comment 0
            }
            continue
        }
        # check if line is a block comment
        set start_comment_block_index [string first $start_block_token $line]
        set end_comment_block_index [string first $end_block_token $line]
        if { $start_comment_block_index != -1 && $end_comment_block_index != -1 } {
            set is_in_block_comment 0
            continue
        } elseif { $start_comment_block_index != -1 } {
            set is_in_block_comment 1
            continue
        }

        # remove inline comments
        set line [lindex [split $line "//"] 0]

        # prevent empty lines
        if {[string trim $line] == ""} {
            continue
        }

        # remove leading and trailing whitespace and return line with single space between tokens
        set tokens [lsearch -all -inline -not -exact [split [string trim $line]] ""]
        lappend result [join $tokens " "]
    }
    close $jack_file
    return $result
}
