
set x "push this 3"
set middle_line [lindex [split $x " "] 1]
set last_value [lindex [split $x " "] end]
puts $middle_line
puts $last_value

switch $middle_line {
    "local" -
     "this" {
        puts "local"
    }
    "remote" {
        puts "remote"
    }
    default {
        puts "default"
    }
}
