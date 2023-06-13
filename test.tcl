set my_dict [dict create a 1 a 2 c 3]

# get the keys
set keys [dict keys $my_dict]
puts $keys

# get the values
set values [dict values $my_dict]
puts $values

# get the values for a specific key
set value [dict get $my_dict a]
puts $value


set constans [list "int" "float" "double" "char" "string" "bool" "void"]
# check if a value is in a list
if {[lsearch -exact $constans "int"] != -1} {
    puts "int is in the list"
}

proc is_even {x} {
    return [expr {($x % 2) == 0}]
}

set x 2
# cheack if x is even
if {[is_even $x]} {
    puts "x is even"
}

proc p0 {my_list_name} {
    upvar 1 $my_list_name my_list

    while { [llength $my_list] > 0} {
        p1 my_list
        set item [lindex $my_list 0]
        puts "my list: $my_list, item: $item"
    }
}

proc p1 {my_list_name} {
    upvar 1 $my_list_name my_list
    set my_list [lrange $my_list 1 end]
    set my_list [lrange $my_list 1 end]
}

# Example usage
set my_list {1 2 3 4 5 6 7 8 9}
p0 my_list
puts $my_list

proc new_node { old_xml new_xml indent_level } {
    set base_space "  "
    set space [string repeat $base_space $indent_level]
    return "$old_xml$space$new_xml"
}

set nn [new_node "<class>\n  <keyword> class </keyword>\n" "<classVarDec>\n" 1]
puts $nn





