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

proc print_queue {my_queue_name} {
    # get the queue reference
    upvar 1 $my_queue_name my_queue
    while { [llength $my_queue] > 0} {
        set item [pop my_queue]
        puts "item: $item"
    }
}

proc pop {my_queue_name} {
    # get the queue reference
    upvar 1 $my_queue_name my_queue
    # get the first item
    set item [lindex $my_queue 0]
    # remove the first item
    set my_queue [lrange $my_queue 1 end]
    return $item
}

# Example usage
set my_queue {1 2 3 4 5 6 7 8 9}
print_queue my_queue
puts $my_queue

proc new_node { old_xml new_xml indent_level } {
    set base_space "  "
    set space [string repeat $base_space $indent_level]
    return "$old_xml$space$new_xml"
}

set nn [new_node "<class>\n  <keyword> class </keyword>\n" "<classVarDec>\n" 1]
puts $nn

oo::class create Person {
    variable name
    constructor {name} {
        name $name
    }

    method print_name {} {
        puts "name: $name"
    }
}

set p1 [Person new "John"]
$p1 print_name


