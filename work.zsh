work() {
  # This is a script to get a specific line from ~/.hw.txt using the second argument 
  # as a substring to search for in the file. If the second argument is not provided, 
  # the script will use the first line in the file. 
  #
  # Then, it will cd to "~/Documents/university/2_year/2_semester/*substring*"` 
  # Then it will open the file in neovim using `nvim *substring*`, and finally
  # It will perform <leader>la to compile the file
  #
  # Usage:
  #  hw [-c] [substring]

  # Define the base directory
  base_dir=~/Documents/university/2_year/2_semester

  # if there is a second arugment and it's data, ssh to server
  if [ "$1" = "grr" ]; then
    if [ "$2" = "borg" ]; then
      ssh mlavrenk@borg13.cs.purdue.edu
    elif [ "$2" = "mc" ]; then
      ssh mlavrenk@mc17.cs.purdue.edu
    else
      ssh mlavrenk@data.cs.purdue.edu
    fi
    return 
  fi

  # Get the substring from the second argument or the first line of the file
  # if there are 3 arguments, the first one is -c, so the substring is the second one
  # if no arguments are provided, the substring is the first line of the file
  if [ -z "$1" ]; then
      substring=$(head -n 1 ~/.hw.txt)
  elif [ "$1" = "-c" ]; then
    substring=$(grep -i "$2" ~/.hw.txt)
  else
    substring=$(grep -i "$1" ~/.hw.txt)
  fi
  
  # echo "Substring: $substring"

  # If the substring is not found, exit
  if [ -z "$substring" ]; then
      echo "No substring found"
      return
  fi

  # Assuming the filename can be directly inferred from substring, adjust as needed
  # if the substring is lab, open lab
  if [[ $substring == *"lab"* ]]; then
    full_path="${base_dir}/ma366/${substring}/"
  else
    full_path="${base_dir}/${substring}/hw/"
  fi

  if [ ! -d "$full_path" ]; then
      echo "Directory does not exist: $full_path"
      return
  fi

  cd "$full_path"
  
  # Out of all the homweork folders in the form of "hw1", "hw2", etc., open the latest one
  # if the substring is lab, check last lab folder instead
  if [[ $substring == *"lab"* ]]; then
    latest_hw=$(ls -d lab* | sort -n | tail -n 1)
  else
    latest_hw=$(ls -d hw* | sort -n | tail -n 1)
  fi

  if [ -z "$latest_hw" ]; then
      echo "No homework folders found"
      return
  fi

  filename="content.tex"
  
  if [ "$1" = "-c" ]; then
    # If the first argument is -c, create a new homework folder with number one greater than the latest one
    # the number is always a 2 digit number (01, 02, etc.)
    # if there are no homework folders, create hw01
    previous_hw="$latest_hw"
    echo $previous_hw
    if [ -z "$latest_hw" ]; then
      latest_hw="hw01"
      if [[ $substring == *"lab"* ]]; then
        latest_hw="lab01"
      fi
    else
      if [[ $substring == *"lab"* ]]; then
        latest_hw=$(echo $latest_hw | sed 's/lab//')
        latest_hw=$(printf "lab%02d" $((10#$latest_hw + 1)))
      else
        latest_hw=$(echo $latest_hw | sed 's/hw//')
        latest_hw=$(printf "hw%02d" $((10#$latest_hw + 1)))
      fi
    fi

    # echo "Creating new homework folder: $latest_hw"

    mkdir "$latest_hw"
    cd "$latest_hw"

    # if the hw to create is hw1, copy the template from .template.tex
    if [[ $latest_hw = "hw01" ]]; then
      cp ~/.template.tex main.tex
    else
      # otherwise, copy the main.tex from the previous homework folder
      # need to go ../ to get to the previous homework folder
      echo "Copying main.tex from $previous_hw"
      cp "../$previous_hw/main.tex" main.tex
      # find the \title in the main.tex and replace the number of the homework
      # the title is in the form of \title{"Course name" Homework/Lab 1}
      # so we just need the last number in the title and replace it with the number of the homework
      # The file name
      file="main.tex"

      # Pattern to match the title line
      pattern="title{.* Homework .*}"
      matched_line=$(grep -o "$pattern" "$file")

      # if matched line is empty, then the pattern is for lab
      if [ -z "$matched_line" ]; then
        pattern="title{.* Lab .*}"
        matched_line=$(grep -o "$pattern" "$file")
      fi

      # echo "Matched line: $matched_line"

      if [ ! -z "$matched_line" ]; then
        # Extract the last number in the line
        # Extract the number that is followed by }
        last_number=$(echo "$matched_line" | grep -o '[0-9]\+' | tail -n 1)
        
        if [ ! -z "$last_number" ]; then
          # Increment the number
          new_number=$((last_number + 1))
          # echo "Incrementing the number in the title from $last_number to $new_number"
          
          # Reverse the line, replace the first occurrence (which is originally the last) of the number, and reverse back
          reversed_matched_line=$(echo "$matched_line" | rev)
          reversed_new_line=$(echo "$reversed_matched_line" | sed "s/$(echo $last_number | rev)/$(echo $new_number | rev)/" | rev)

          # Now, $reversed_new_line contains the original line but with the last occurrence of the number incremented
          new_line=$reversed_new_line

          # Escape special characters in the original and new lines for sed replacement
          escaped_matched_line=$(echo "$matched_line" | sed 's/[\/&]/\\&/g')
          escaped_new_line=$(echo "$new_line" | sed 's/[\/&]/\\&/g')

          # Use sed to replace the line in the file. Since we are on macOS, remember the '' after -i to avoid backup
          sed -i '' "s/${escaped_matched_line}/${escaped_new_line}/" "$file"

          # echo "Replaced '$matched_line' with '$new_line' in $file."
                        
        else
          echo "No number found to increment."
        fi
      else
        echo "The pattern was not found in the file."
      fi    
    fi

    # echo "Creating $filename"
    touch $filename
    pdflatex main.tex

    # Open the file in neovim with the necessary commands
    nvim "$filename" \
      -c ':set filetype=tex' \
      -c ':VimtexCompile' \
      -c ':term source ~/.zshrc && pdf' \
      -c ':bnext' \
      #-c ':term' \

    return
  fi

  # if there is no argument -c, but there is an argument $2, open the homework with that number
  if [ ! -z "$2" ] && [ "$1" != "-c" ] ; then
    latest_hw=$(printf "hw%02d" $2)
    if [[ $substring == *"lab"* ]]; then
      latest_hw=$(printf "lab%02d" $2)
    fi
  fi
  # echo "Opening homework folder: $latest_hw"
  cd "$latest_hw"

  # Check if the file exists
  if [ ! -f "$filename" ]; then
      echo "File does not exist: $filename"
      return
  fi

  # Open the file in neovim with the necessary commands
  nvim "$filename" \
    -c ':set filetype=tex' \
    -c ':VimtexCompile' \
    -c ':term source ~/.zshrc && pdf' \
    -c ':bnext' \
}
