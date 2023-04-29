

proc remove_inline_comments {line} {
    return [regsub -all {\/\/.*$} $line ""]
}

puts [remove_inline_comments "hello // world // this is a comment"]