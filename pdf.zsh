pdf() {
  # This is a script to open a pdf file in sioyek
  # If not argument is provided, it will open the first pdf file 
  # found in the current directory or main.pdf if it exists
  # If there are no pdf files in the current directory, 
  # it will open sioyek without any arguments
  #
  # Usage:
  # pdf [file]

  if [ -f "3" ]; then
    rm 3
  fi 

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
#    printf "Found ${#pdfs[@]} pdf files\n"
#    printf "Files: ${pdfs} \n"

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
      # check if the last
      # character of $1 is a dot
      if [[ $1 == *. ]]; then
        printf "Replacing extension of $1 with .pdf\n"
        set -- "${1%.*}".pdf
      fi
      # search for the corresponding pdf file
      # get a list of pdf files in the current directory
      pdfs=($(find . -maxdepth 1 -type f -name "*.pdf"))
      # check if $1 is a substring of any of the pdf files
      for pdf in "${pdfs[@]}"; do
        if [[ $pdf == *"$1"* ]]; then
          printf "Found $pdf\n"
          sioyek "$pdf"
          return
        fi
      done
      printf "No pdf file found for $1\n"
      sioyek
      return
    fi
    printf "Opening $1\n"
    sioyek "$1"
  fi
}
