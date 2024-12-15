myremove() {
  # this is an alternative to the remove command
  # that puts the files in the trash instead of 
  # deleting them forever
  # usage: rr [-r] file1 file2 file3 ...
  
  if [ "$1" = "-r" ]; then
    shift
    for file in "$@"; do
      mv "$file" ~/.Trash
    done
  else
    for file in "$@"; do
      mv "$file" ~/.Trash
    done
  fi 
}
