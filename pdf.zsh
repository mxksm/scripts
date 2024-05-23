pdf() {
  # This is a script to open a pdf file in sioyek
  # If not argument is provided, it will open the first pdf file 
  # found in the current directory or main.pdf if it exists
  # If there are no pdf files in the current directory, 
  # it will open sioyek without any arguments
  #
  # Usage:
  # pdf [file]
  
  if [ -z "$1" ]; then
    # No argument provided, find a pdf file in the current directory
    # and open it
    printf "No argument provided, finding a pdf file in the current directory\n"

    # check if there are no pdf files in the current directory
    pdfs=($(find . -maxdepth 1 -type f -name "*.pdf"))
    
    # Check if no PDF files were found
    if [ ${#pdfs[@]} -eq 0 ]; then
      printf "No pdf files found in the current directory\n"
      sioyek
      return
    fi
    
    pdfs=(*.pdf)
    printf "Found ${#pdfs[@]} pdf files\n"
    printf "Files: ${pdfs} \n"

    # if main.pdf exists, open it
    if [ -f "main.pdf" ]; then
      printf "Found main.pdf\n"
      sioyek main.pdf
      return
    fi

    # otherwise open the first pdf file found
    if [ -z "$pdfs" ]; then
      printf "No pdf files found in the current directory\n"
      sioyek
    else
      printf "Opening ${pdfs[@]}\n"
      sioyek "${pdfs[@]}"
    fi
  else
    # Argument provided, open the specified file
    # check if the file already has the .pdf extension
    if [[ $1 != *.pdf ]]; then
      # check if $1 already has the dot in it
      if [[ $1 != *. ]]; then
        # if not, add it
        printf "Adding .pdf extension to $1\n"
        set -- "$1".pdf
      else
        # if yes, replace it with .pdf
        printf "Replacing extension of $1 with .pdf\n"
        set -- "${1%.*}".pdf
      fi
    fi
    printf "Opening $1\n"
    sioyek "$1"
  fi
}
