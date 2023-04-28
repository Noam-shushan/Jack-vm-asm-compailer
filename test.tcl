

set obj {}
set code [list a 1 b 2 c 3]
set rows [join $code "\n"]
lappend obj "$rows \n\n" 
lappend obj {*}[list "noam" "dan"]

puts [join $obj ""]
