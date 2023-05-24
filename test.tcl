proc ff { } {
    return [list "BasicLoop.tst" "noam" "sara"]
}

set str "../../projects/08/ProgramFlow/BasicLoop/"
set path_split [split $str "/"]
set path_split [concat $path_split [ff]]
puts $path_split 