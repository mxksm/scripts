opn() {
  # if the file ($1) is a png or mp4, use mpv to open it. 
  # otherwise, use the default mac open command

  if [[ $1 == *.png || $1 == *.mp4 ]]; then
    mpv "$1"
  else
    open "$1"
  fi
}
