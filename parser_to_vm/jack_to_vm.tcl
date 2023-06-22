# Harel Yehiel 316334259
# Yahav David-Zada 318356268

#!/bin/sh
# Parser.tcl \
exec tclsh "$0" ${1+"$@"}

oo::class create Symbol {
	variable name
	variable var_type
	variable var_kind
	variable id
	constructor {name2 var_type2 kind2 id2} {
		set name  $name2
		set var_type  $var_type2
		set var_kind  $kind2
		set id  $id2
	}
	method get_name {} {
		return $name
	}
	method get_var_type {} {
		return $var_type
	}
	method get_var_kind {} {
		return $var_kind
	}
	method get_id {} {
		return $id
	}
}

oo::class create symbolTable {
	variable tbl
	constructor {} {
		set tbl {}
	}
	method define {name2 var_type2  kind2} {
		set id 0
		for {set i 0} {$i<[llength $tbl]} {incr i} {
			if {  [[lindex $tbl $i] get_var_kind] == $kind2 } {
				if {[[lindex $tbl $i] get_id]>$id} {
					set id [lindex $tbl $i] get_id
				} elseif { [[lindex $tbl $i] get_id] == $id } {
					incr id
				}
			}
		}
		lappend tbl [Symbol new $name2 $var_type2 $kind2 $id]
	}

	method varCount {kind2} {
		set counter 0

		for {set i 0} {$i<[llength $tbl]} {incr i} {
			if {  [[lindex $tbl $i] get_var_kind] == $kind2 } {
				incr counter
			}
		}
		return $counter

	}

	method kindOf {name2} {
		set id 0
		for {set i 0} {$i<[llength $tbl]} {incr i} {
			if {  [[lindex $tbl $i] get_name] == $name2 } {
				if {  [[lindex $tbl $i] get_var_kind] == "var" } {
					return "local"
				}
				if {  [[lindex $tbl $i] get_var_kind] == "field" } {
					return "this"
				}

				return [[lindex $tbl $i] get_var_kind]
			}
		}
		return ""
	}

	method typeOf {name2} {
		set id 0
		for {set i 0} {$i<[llength $tbl]} {incr i} {
			if {  [[lindex $tbl $i] get_name] == $name2 } {
				return [[lindex $tbl $i] get_var_type]
			}
		}
		return ""
	}

	method indexOf {name2} {
		set id 0
		for {set i 0} {$i<[llength $tbl]} {incr i} {
			if {  [[lindex $tbl $i] get_name] == $name2 } {
				return [[lindex $tbl $i] get_id]
			}
		}
		return 0
	}
	method restart {} {
		set tbl {}
	}
}














set OP  {"+" "-" "*" "/" "&amp;" "|" "&lt;" "&gt;" "="}
set txt  ""
lappend currentToken ""
lappend currentToken ""
set result  ""

set vm ""
set if_counter  0
set while_counter  0

set classScope [symbolTable new]
set currentClass ""

set subScope [symbolTable new]
set currentSub {}
lappend currentSub ""
lappend currentSub ""


proc init {data} {
	global txt
	global vm
	global classScope
	global subScope
	global if_counter
	global while_counter
	global currentClass
	global currentSub
	set txt $data
	set vm ""
	set if_counter  0
	set while_counter  0

	$classScope restart
	set currentClass ""

	$subScope restart
	set currentSub {}
	lappend currentSub ""
	lappend currentSub ""
	parse

	return $vm

}
proc subReset {} {
	global if_counter
	global subScope
	global while_counter
	set subScope [symbolTable new]
	set if_counter 0
	set while_counter 0
}

proc kindOf {name} {
	global subScope
	global classScope
	return "[$subScope kindOf $name][$classScope kindOf $name]"
}

proc typeOf {name} {
	global subScope
	global classScope
	return "[$subScope typeOf $name][$classScope typeOf $name]"
}

proc varCount {kind} {
	global subScope
	global classScope
	return [expr {[$subScope varCount $kind]+[$classScope varCount $kind]}]
}

proc indexOf {name} {
	global subScope
	global classScope
	return [expr {[$subScope indexOf $name]+[$classScope indexOf $name]}]
}



proc getToken {data} {
	set txt $data
	global currentToken
	if {[string first "\n" $txt]  != -1} {
		set txt [string range $txt 0 [string first "\n" $txt]]
		set start1 [string first "<" $txt]
		set end1 [string first ">" $txt]
		set start2 [string first " " $txt]
		set end2 [string last " " $txt]
		if {$start1 != -1 && $end1 != -1 && $start2 !=-1 && $end2 != -1} {
			lappend ret [string range $txt [expr {$start1 + 1}]   [expr {$end1 - 1}]]
			lappend ret [string range $txt [expr {$start2 + 1}]  [expr {$end2 - 1}]]
			return $ret
		}
	}
	return $currentToken
}

proc nextToken {} {
	global txt
	global currentToken
	if {[string first "\n" $txt]  != -1} {
		set txt [string range $txt [expr {[string first "\n" $txt] + 1}] end]
	}
	set currentToken [getToken $txt]
}

proc checkNextToken {{lookAhead 1}} {
	global txt
	set i 0
	set result $txt
	while {$i<$lookAhead} {
		if {[string first "\n" $txt] != -1 } {
			set result [string range $result [expr {[string first "\n" $result] + 1}] end]
		}
		set i [expr {$i + 1}]
	}
	return [getToken $result]
}

proc addNextToken {} {
	global currentToken
	global result
	nextToken
	set result "$result <[lindex $currentToken 0]> [lindex $currentToken 1] </[lindex $currentToken 0]>\n"
}




proc parse {} {
	global currentClass
	global currentToken
	global currentSub
	nextToken
	nextToken
	set currentClass [lindex $currentToken 1]
	nextToken
	classVarDec
	subroutineDec
	nextToken
}

proc classVarDec {} {
	global classScope
	global currentToken
	while {[lindex [checkNextToken ] 1] == "static" || [lindex [checkNextToken ] 1] == "field"} {
		nextToken
		set kind [lindex $currentToken 1]
		nextToken
		set var_type [lindex $currentToken 1]
		nextToken
		set name [lindex $currentToken 1]
		$classScope define $name $var_type $kind
		while {[lindex [checkNextToken ] 1] == ","} {
			nextToken
			nextToken
			set name [lindex $currentToken 1]
			$classScope define $name $var_type $kind
		}
		nextToken
	}
}

proc subroutineDec {} {
	global currentToken
	global currentSub

	while {[lindex [checkNextToken ] 1] == "constructor" ||[lindex [checkNextToken ] 1] == "function" ||[lindex [checkNextToken ] 1] == "method"} {
		subReset
		nextToken
		set currentSub [lreplace $currentSub 0 0 [lindex $currentToken 1]]
		nextToken
		nextToken
		set currentSub [lreplace $currentSub 1 1 [lindex $currentToken 1]]
		nextToken
		parameterList
		nextToken
		set id [varCount "local"]
		subroutineBody
	}
}

proc parameterList {} {
	global currentClass
	global subScope
	global currentToken
	global currentSub
	set name ""
	set var_type ""
	if {[lindex $currentSub 0] == "method"} {
		$subScope define "this" $currentClass "argument"
	}
	if {[lindex [checkNextToken ] 1] != ")"} {
		nextToken
		set var_type [lindex $currentToken 1]
		nextToken
		set name [lindex $currentToken 1]
		$subScope define $name $var_type "argument"
	}
	while {[lindex [checkNextToken ] 1] == ","} {
		nextToken
		nextToken
		set var_type [lindex $currentToken 1]
		nextToken
		set name [lindex $currentToken 1]
		$subScope define $name $var_type "argument"
	}
}


proc subroutineBody {} {
	global currentClass
	global currentSub
	global varCount
	global vm
	nextToken
	varDec
	set vm "$vm\nfunction $currentClass\.[lindex $currentSub 1] [varCount var]\n"
	if {[lindex $currentSub 0] == "constructor"} {
		set vm "$vm\push constant [varCount field]\n"
		set vm "$vm\call Memory.alloc 1\n"
		set vm "$vm\pop pointer 0\n"
	} elseif {[lindex $currentSub 0] == "method"} {
		set vm "$vm\push argument 0\n"
		set vm "$vm\pop pointer 0\n"
	}
	statements
	nextToken
}

proc varDec {} {
	global currentToken
	global subScope
	set name ""
	set var_type ""
	while {[lindex [checkNextToken ] 1] == "var"} {
		nextToken
		nextToken
		set var_type [lindex $currentToken 1]
		nextToken
		set name [lindex $currentToken 1]
		$subScope define $name $var_type "var"
		while {[lindex [checkNextToken ] 1] == ","} {
			nextToken
			nextToken
			set name [lindex $currentToken 1]
			$subScope define $name $var_type "var"
		}
		nextToken
	}
}

proc statements {} {
	global vm
	global currentToken
	while {[lindex [checkNextToken ] 1] != "\}"} {
		if {[lindex [checkNextToken ] 1]=="let" } {
			letStatement
		}
		if {[lindex [checkNextToken ] 1]=="do"} {
			doStatement
			set vm "$vm\pop temp 0\n";
		}
		if {[lindex [checkNextToken ] 1]=="while"} {
			whileStatement
		}
		if {[lindex [checkNextToken ] 1]=="if"} {
			ifStatement
		}
		if {[lindex [checkNextToken ] 1]=="return"} {
			returnStatement
		}
	}
}

proc letStatement {} {
	global vm
	global currentToken
	nextToken
	nextToken

	if {[lindex [checkNextToken ] 1] == "\["} {
		set isArr true
	} else {
		set isArr false
	}
	set tmp ""
	if {$isArr} {
		set index [indexOf [lindex $currentToken 1]]
		set kind [kindOf [lindex $currentToken 1]]
		set tmp  "push [kindOf [lindex $currentToken 1]] [indexOf [lindex $currentToken 1]]\n";
		nextToken
		expression
		set vm "$vm$tmp\nadd\n"
		nextToken
	} else {
		set index [indexOf [lindex $currentToken 1]]
		set kind [kindOf [lindex $currentToken 1]]

		set tmp "$tmp\pop $kind $index\n"
	}
	nextToken
	expression
	nextToken

	if {$isArr} {
		set vm "$vm\pop temp 0\n\pop pointer 1\n\push temp 0\n\pop that 0\n"
	} else {
		set vm "$vm$tmp"
	}

}

proc doStatement {} {
	nextToken
	subroutineCall 0
	nextToken
}


proc whileStatement {} {
	global while_counter
	global vm
	set index $while_counter
	set while_counter [expr {$while_counter + 1}]
	set vm "$vm\label WHILE_EXP$index\n"
	nextToken
	nextToken
	expression
	nextToken
	set vm "$vm\nnot\n"
	set vm "$vm\if-goto WHILE_END$index\n"
	nextToken
	statements
	nextToken
	set vm "$vm\goto WHILE_EXP$index\n"
	set vm "$vm\label WHILE_END$index\n"
}

proc ifStatement {} {
	global if_counter
	global vm
	set index $if_counter
	set if_counter [expr {$if_counter + 1}]
	nextToken
	nextToken
	expression
	nextToken
	set vm "$vm\if-goto IF_TRUE$index\n"
	set vm "$vm\goto IF_FALSE$index\n"
	set vm "$vm\label IF_TRUE$index\n"
	nextToken
	statements
	nextToken
	if {[lindex [checkNextToken ] 1] == "else"} {
		set vm "$vm\goto IF_END$index\n"
	}
	set vm "$vm\label IF_FALSE$index\n"
	if {[lindex [checkNextToken ] 1]=="else" && [lindex [checkNextToken ] 0]=="keyword"} {
		nextToken
		nextToken
		statements
		nextToken
		set vm "$vm\label IF_END$index\n"
	}
}


proc returnStatement {} {
	global vm
	nextToken
	if {!([lindex [checkNextToken ] 0]=="symbol" && [lindex [checkNextToken ] 1]==";")} {
		expression
	} else {
		set vm "$vm\push constant 0\n"
	}
	set vm "$vm\nreturn\n"
	nextToken

}

proc expression {} {
	global OP
	global currentToken
	global vm
	term
	while {[lsearch -exact $OP [lindex [checkNextToken ] 1]] != -1} {
		set op ""
		nextToken
		if {[lindex $currentToken 1] == "+"} {
			set op "$op\nadd\n"
		}
		if {[lindex $currentToken 1] == "-"} {
			set op "$op\sub\n"
		}
		if {[lindex $currentToken 1] == "/"} {
			set op "$op\call Math.divide 2\n"
		}
		if {[lindex $currentToken 1] == "*"} {
			set op "$op\call Math.multiply 2\n"
		}
		if {[lindex $currentToken 1] == "&amp;"} {
			set op "$op\nand\n"
		}
		if {[lindex $currentToken 1] == "|"} {
			set op "$op\or\n"
		}
		if {[lindex $currentToken 1] == "&lt;"} {
			set op "$op\lt\n"
		}
		if {[lindex $currentToken 1] == "&gt;"} {
			set op "$op\gt\n"
		}
		if {[lindex $currentToken 1] == "="} {
			set op "$op\eq\n"
		}
		term
		set vm "$vm$op"
	}
}



proc term {} {
	global currentToken
	global vm
	if {[lindex [checkNextToken ] 0] == "integerConstant" || [lindex [checkNextToken ] 0] == "stringConstant" || [lindex [checkNextToken ] 0] == "keyword" } {
		nextToken
		if {[lindex $currentToken 0] == "integerConstant"} {
			set vm "$vm\push constant [lindex $currentToken 1]\n"
		} elseif { [lindex $currentToken 0] == "stringConstant" } {
			set len [string length [lindex $currentToken 1]]
			set vm "$vm\push constant $len\n"
			set vm "$vm\call String.new 1\n"
			for {set i 0} {$i<[expr {$len}]} {incr i} {
				set char [string index [lindex $currentToken 1] $i]
				scan $char %c char_value
				set vm "$vm\push constant $char_value\n"
				set vm "$vm\call String.appendChar 2\n"
			}
		} elseif {[lindex $currentToken 1] == "false" || [lindex $currentToken 1] == "null"} {
			set vm "$vm\push constant 0\n"
		} elseif {[lindex $currentToken 1] == "true"} {
			set vm "$vm\push constant 0\n"
			set vm "$vm\nnot\n"
		} elseif {[lindex $currentToken 1] == "this"} {
			set vm "$vm\push pointer 0\n"
		}
	} elseif { [lindex [checkNextToken ] 0] == "identifier"} {
		if {[lindex [checkNextToken 2] 1] == "\["} {
			nextToken
			set tmp "push [kindOf [lindex $currentToken 1]] [indexOf [lindex $currentToken 1]]\n"
			nextToken
			expression
			nextToken
			set vm "$vm$tmp"
			set vm "$vm\nadd\n"
			set vm "$vm\pop pointer 1\n"
			set vm "$vm\push that 0\n"

		} elseif { [lindex [checkNextToken 2] 1] == "(" || [lindex [checkNextToken 2] 1] == "." } {
			if {[lindex [checkNextToken 2] 1] == "("} {
				subroutineCall true
			} else {
				subroutineCall false
			}

		} else {
			nextToken
			set vm "$vm\push [kindOf [lindex $currentToken 1]] [indexOf [lindex $currentToken 1]]\n"
		}
	} elseif { [lindex [checkNextToken ] 1] == "(" } {
		nextToken
		expression
		nextToken
	} elseif { [lindex [checkNextToken ] 1] == "_" ||[lindex [checkNextToken ] 1] == "-" || [lindex [checkNextToken ] 1] == "~"} {
		nextToken
		set tmp ""
		if {[lindex $currentToken 1] == "_" || [lindex $currentToken 1] == "-" || [lindex $currentToken 1] != "~"} {
			set tmp "$tmp\nneg\n"
		} else  {
			set tmp "$tmp\nnot\n"
		}
		term
		set vm "$vm$tmp"
	}
}

proc subroutineCall {{cond 1}} {
	global currentToken
	global vm
	global currentClass
	if {[lindex [checkNextToken 2] 1] == "(" } {
		nextToken
		if {[kindOf [lindex $currentToken 1]]==""} {
			set isMethod  true
		} else {
			set isMethod  false
		}
		set numOfArg 0
		set vm "$vm\push pointer 0\n"
		set tmp ""
		set tmp "$tmp\call $currentClass\.[lindex $currentToken 1]"

		if {[lindex $currentToken 1] == "lose"||[lindex $currentToken 1] == "win"} {
			set isMethod  true
		}
		nextToken
		set numOfArg [expr {$numOfArg + [expressionList]}]

		if {$isMethod} {
			set numOfArg [expr {$numOfArg + 1}]
		}
		set tmp "$tmp $numOfArg\n"
		set vm "$vm$tmp"
		nextToken
	} elseif { [lindex [checkNextToken 2] 1] == "." } {
		nextToken
		if {[kindOf [lindex $currentToken 1]] != ""} {
			set isMethod  true
		} else {
			set isMethod  false
		}
		set numOfArgs 0
		set classCall [lindex $currentToken 1]
		if {$isMethod} {
			set numOfArgs [expr {$numOfArgs + 1}]
			set classCall [typeOf [lindex $currentToken 1]]
			set vm "$vm\push [kindOf [lindex $currentToken 1]] [indexOf [lindex $currentToken 1]]\n"
		}

		set tmp "call $classCall\."
		nextToken
		nextToken
		set tmp "$tmp[lindex $currentToken 1] "
		nextToken
		set numOfArgs [expr {$numOfArgs + [expressionList]}]
		set tmp "$tmp$numOfArgs\n"
		set vm "$vm$tmp"
		nextToken
	}

}

proc expressionList {} {
	set counter 0
	if {[lindex [checkNextToken ] 1] != ")" } {
		expression
		set counter [expr {$counter + 1}]
		while {[lindex [checkNextToken ] 1] == ","} {
			set counter [expr {$counter + 1}]
			nextToken
			expression
		}
	}
	return $counter
}

#!/bin/sh
# Tokenizer.tcl \
exec tclsh "$0" ${1+"$@"}


set CURRENT_VALUE  ""
set CURRENT_TOKEN  ""
set KEYWORDS {"class" "constructor" "function" "method" "field" "static" "var" "int" "char" "boolean" "void" "true" "false" "null" "this" "let" "do" "if" "else" "while" "return"}
set SYMBOLS  {"{" "}" "(" "\)" "[" "]" "." "," ";" "+" "-" "*" "/" "&" "|" "<" ">" "=" "~"}


proc tokenizer {data} {
	global CURRENT_VALUE
	global CURRENT_TOKEN
	global KEYWORDS
	global SYMBOLS
	set result "<tokens>\n"

	set txt $data

	while {0<[string length $txt]} {
		set char [string index $txt 0]
		set txt [string range $txt 1 end]
		scan $char %c char_value
		set CURRENT_VALUE $char
		if {$char == "/"} {
			set temp [handleSlash $txt]
			set txt [lindex $temp 0]
			set tmp [lindex $temp 1]
			if {$tmp !=""} {
				set result "$result$tmp"
			}
		} elseif  {($char_value >= 97 && $char_value <= 122) || ($char_value >= 65 && $char_value <= 90) || $char_value == 95} {
			set temp [handle_char $txt]
			set txt [lindex $temp 0]
			set tmp [lindex $temp 1]
			if {$tmp !=""} {
				set result "$result$tmp"
			}
		} elseif  {$char_value >= 48 && $char_value <= 57} {
			set temp [handleDigit $txt]
			set txt [lindex $temp 0]
			set tmp [lindex $temp 1]
			if {$tmp !=""} {
				set result "$result$tmp"
			}
		} elseif  {[lsearch -exact $SYMBOLS $char]  != -1} {
			set temp [handleSymbol $txt]
			#set txt [lindex $temp 0]
			set tmp [lindex $temp 1]
			if {$tmp !=""} {
				set result "$result$tmp"
			}
		} elseif  {$char == "\""} {
			set temp [handleString $txt]
			set txt [lindex $temp 0]
			set tmp [lindex $temp 1]
			if {$tmp !=""} {
				set result "$result$tmp"
			}
		}
	}

	set result "$result</tokens>\n"
	set CURRENT_VALUE ""
	set CURRENT_TOKEN ""
	#puts $result

	return $result
}

proc handle_char {txt } {
	global CURRENT_VALUE
	global CURRENT_TOKEN
	global KEYWORDS
	global SYMBOLS
	if {$CURRENT_VALUE == "_"} {
		set CURRENT_TOKEN "identifier"
	} else {
		set CURRENT_TOKEN "keyword"
	}

	while {0<[string length $txt]} {

		set char [string index $txt 0]
		scan $char %c char_value
		if {( $char_value >= 97 && $char_value <= 122) || ( $char_value >= 65 && $char_value <= 90) || $char_value == 95} {

			if {$CURRENT_VALUE == "keyword" && $char == "_"} {
				set CURRENT_TOKEN "identifier"
			}
		} elseif { ( $char_value >= 48 && $char_value <= 57) && $CURRENT_TOKEN == "keyword" } {
			set CURRENT_TOKEN "identifier"
		} else {
			if {$CURRENT_TOKEN == "identifier" || [lsearch -exact $KEYWORDS $CURRENT_VALUE]  == -1} {
				set CURRENT_TOKEN "identifier"
			}
			break
		}
		set CURRENT_VALUE  "$CURRENT_VALUE$char"
		set txt [string range $txt 1 end]
	}

	set ret {}
	lappend ret $txt
	lappend ret [writeToken ]
	return $ret
}

proc handleDigit {txt} {
	global CURRENT_VALUE
	global CURRENT_TOKEN
	global KEYWORDS
	global SYMBOLS
	set CURRENT_TOKEN  "integerConstant"
	while {0<[string length $txt]} {
		set char [string index $txt 0]
		scan $char %c char_value

		if {$char_value >= 48 && $char_value <= 57} {
			set CURRENT_VALUE  "$CURRENT_VALUE$char"
			set txt [string range $txt 1 end]
		} else {
			break
		}
	}

	lappend ret $txt
	lappend ret [writeToken ]
	return $ret
}

proc handleSymbol {txt} {
	global CURRENT_VALUE
	global CURRENT_TOKEN
	global KEYWORDS
	global SYMBOLS
	set CURRENT_TOKEN  "symbol"
	if {$CURRENT_VALUE == "<"} {
		set CURRENT_VALUE  "&lt;"
	}
	if {$CURRENT_VALUE == ">"} {
		set CURRENT_VALUE  "&gt;"
	}
	if {$CURRENT_VALUE == "\""} {
		set CURRENT_VALUE  "&quet;"
	}
	if {$CURRENT_VALUE == "&"} {
		set CURRENT_VALUE  "&amp;"
	}
	lappend ret $txt
	lappend ret [writeToken ]
	return $ret
}

proc handleString {txt} {
	global CURRENT_VALUE
	global CURRENT_TOKEN
	global KEYWORDS
	global SYMBOLS

	set CURRENT_TOKEN  "stringConstant"
	set CURRENT_VALUE  ""
	while {0<[string length $txt]} {
		set char [string index $txt 0]
		set txt [string range $txt 1 end]
		if {$char == "\"" } {
			break
		} else {
			set CURRENT_VALUE  "$CURRENT_VALUE$char"
		}
	}

	set ret {}
	lappend ret $txt
	lappend ret [writeToken ]
	return $ret

}

proc handleSlash {txt} {
	set char [string index $txt 0]
	if {$char == "/"} {
		if {[string first "\n" $txt]  != -1} {
			lappend ret [string range $txt [string first "\n" $txt] end]
			lappend ret ""
			return $ret
		}
		set CURRENT_VALUE ""
		lappend ret ""
		lappend ret ""
		return $ret
	} elseif {$char == "*"} {
		if {[string first "*/" $txt]  != -1} {
			set num [string first "*/" $txt]
			lappend ret [string range $txt [expr {$num + 2}] end]
			lappend ret ""
			return $ret
		}
	} else {
		return [handleSymbol $txt]
	}
	lappend ret $txt
	lappend ret ""
	return $ret
}

proc writeToken {} {
	global CURRENT_VALUE
	global CURRENT_TOKEN
	global KEYWORDS
	global SYMBOLS
	return "<$CURRENT_TOKEN> $CURRENT_VALUE </$CURRENT_TOKEN>\n"

}


#!/bin/sh
# Symbol.tcl \
exec tclsh "$0" ${1+"$@"}




oo::class create Symbol {
	variable name
	variable var_type
	variable var_kind
	variable id
	constructor {name2 var_type2 kind2 id2} {
		set name  $name2
		set var_type  $var_type2
		set kind  $kind2
		set id  $id2

	}
	method get_name {} {
		return $name
	}
	method get_var_type {} {
		return $var_type
	}
	method get_var_kind {} {
		return $var_kind
	}
	method get_id {} {
		return $id
	}
}

oo::class create symbolTable {
	variable tbl
	constructor {} {


	}

	method define {name2 var_type2  kind2} {
		set id 0
		for {set i 0} {$i<[llength $tbl]} {incr i} {
			if {  [lindex $tbl $i] $var_kind == $kind2 } {
				if {[lindex $tbl $i] get_id>$id} {
					set id [lindex $tbl $i] get_id
				}
				elseif { [lindex $tbl $i] get_id == $id } {
					incr id
				}
			}
		}
		lappend tbl [Symbol new name2 var_type2 kind2 id]

	}

	method varCount {kind2} {
		set id 0
		for {set i 0} {$i<[llength $tbl]} {incr i} {
			if {  [lindex $tbl $i] get_var_kind == $kind2 } {
				incr counter
			}
		}
		return $counter

	}

	method kindOf {name2} {
		set id 0
		for {set i 0} {$i<[llength $tbl]} {incr i} {
			if {  [lindex $tbl $i] get_name == $name2 } {
				if {  [lindex $tbl $i] get_var_kind == "var" } {
					return "local"
				}
				if {  [lindex $tbl $i] get_var_kind == "field" } {
					return "this"
				}
			}
		}
		return ""

	}

	method typeOf {name2} {
		set id 0
		for {set i 0} {$i<[llength $tbl]} {incr i} {
			if {  [lindex $tbl $i] get_name == $name2 } {
				return [lindex $tbl $i] get_var_type
			}
		}
		return ""

	}

	method indexOf {name2} {
		set id 0
		for {set i 0} {$i<[llength $tbl]} {incr i} {
			if {  [lindex $tbl $i] get_name == $name2 } {
				return [lindex $tbl $i] get_id
			}
		}
		return 0

	}

}

lappend currentToken "aas"
lappend currentToken "iii"

lappend tmp [lindex $currentToken 0]
set currentToken [lreplace $currentToken 1 1 "ssssssssssss"]
puts $currentToken

#!/bin/sh
# main.tcl \
exec tclsh "$0" ${1+"$@"}


# source "../tokenizer/tokenizer.tcl"
# source "../file_handler.tcl"

# puts "Enter a file full path: "

# # C:\Users\POSEIDON\nand2tetrisFolder\nand2tetris\projects\11\Pong

# set answer ""


# tokenize_dir $root

set jackT_files [glob -directory $root -nocomplain -type f *T.xml]
foreach jack_tokens_file $jackT_files {
	set file_path [file join $root $jack_file]
	set file_name_with_ex [file tail $file_path]
	set file_name_without_ex [file rootname $file_name_with_ex]
	set file_content [read_file $file_path]

	set answer [init $answer]
	set write_file [open "$root/[file rootname  [file tail $file_path]].vm"  w+]
	puts $write_file $answer
	close $write_file
}

