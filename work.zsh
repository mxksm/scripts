newfolder() {
  # If the first argument is -c, create a new homework folder 
  # with number one greater than the latest one
  # the number is always a 2 digit number (01, 02, etc.)
  # if there are no homework folders, create hw01
  previous_hw="$latest_hw"
  if [ -z "$latest_hw" ]; then
    latest_hw="hw01"
  else
    latest_hw=$(echo $latest_hw | sed 's/hw//')
    latest_hw=$(printf "hw%02d" $((10#$latest_hw + 1)))
  fi

  echo "Creating new homework folder: $latest_hw"

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
    # the title is in the form of \title{"Course name" Homework 1}
    # so we just need the last number in the title and replace it 
    # with the number of the homework
    # The file name
    file="main.tex"

    # Pattern to match the title line
    pattern="title{.* Homework .*}"
    matched_line=$(grep -o "$pattern" "$file")

    # echo "Matched line: $matched_line"
    if [ ! -z "$matched_line" ]; then
      # Extract the last number in the line
      # Extract the number that is followed by }
      last_number=$(echo "$matched_line" | grep -o '[0-9]\+' | tail -n 1)
      
      if [ ! -z "$last_number" ]; then
        # Increment the number
        new_number=$((last_number + 1))
        # echo "Incrementing the number in the title from $last_number to $new_number"
        
        # Reverse the line, replace the first occurrence (which is originally the last) 
        # of the number, and reverse back
        reversed_matched_line=$(echo "$matched_line" | rev)
        reversed_new_line=$(echo "$reversed_matched_line" | sed "s/$(echo $last_number | rev)/$(echo $new_number | rev)/" | rev)

        # Now, $reversed_new_line contains the original line but with the last 
        # occurrence of the number incremented
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
  nvimopen

  return
}

choose() {
  # This is a script to choose a substring from a list of substrings
  # provided as the first argument. The list is provided as a string
  # with substrings separated by a space. The script will print the 
  # list of substrings with numbers and prompt the user to choose one.
  #
  # Usage:
  #  choose "substring1 substring2 substring3"

  # if the first argument is empty, exit
  echo "Courses:"
  for i in $(seq 1 $(echo "$substring_list" | wc -l)); do
    echo "$i: $(echo "$substring_list" | sed -n "${i}p")"
  done

  # prompt the user to choose one
  echo "Choose one:"
  read substring

  # if the user input is not a number, exit
  if ! [[ $substring =~ ^[0-9]+$ ]]; then
    echo "Not a number"
    return
  fi

  # if it is, choose the string corresponding to the number
  number=$(echo "$substring" | sed -n "${substring}p")

  # choose the substring as the string in the list
  # corresponding to the number
  substring=$(echo "$substring_list" | sed -n "${substring}p")
  echo "Chosen substring: $substring"
}

server() {
  srvr=$1 
  if [ "$1" = "grr" ]; then
    ssh mlavrenk@data.cs.purdue.edu
  else
    ssh -i ~/.ssh/id_rsa_purdue mlavrenk@scholar.rcac.purdue.edu
  fi
}

nvimopen() {
  # check if file exists 
  if [ ! -f "$filename" ]; then
    filename="main.tex"
  fi

  if [ ! -f "$filename" ]; then
    echo "File does not exist: $filename"
    return
  fi

  nvim "$filename" \
      -c ':set filetype=tex' \
      -c ':VimtexCompile' \
      -c ':term source ~/.zshrc && pdf && rm main\ ?*' \
      -c ':bnext' \
}


work() {
  # This is a script to get a specific line from ~/.hw.txt using the second argument 
  # as a substring to search for in the file. If the second argument is not provided, 
  # the script will use the first line in the file. 
  #
  # Then, it will cd to "~/Documents/university/3_year/2_semester/*substring*"` 
  # Then it will open the file in neovim using `nvim *substring*`, and finally
  # It will perform <leader>la to compile the file
  #
  # Usage:
  #  hw [-c] [-cd] [substring]

  # Define the base directory
  base_dir=~/Documents/university/3_year/2_semester
  mlnotes=~/Documents/university/MLnotes

  if [ "$1" = "h" ] || [ "$1" = "-h" ]; then
    # work here
    filename="content.tex"
    # if $2 is main, open the main.tex file
    if [ "$2" = "main" ] || [ "$2" = "m" ]; then
      filename="main.tex"
    fi
    nvimopen
    return
  fi

  if [ "$1" = "hm" ]; then
    filename="main.tex"
    nvimopen
    return
  fi

  if [ "$1" = "resume" ]; then
    cd ~/Documents/maxinimus.github.io/files/resume/
    filename="resume.tex"
    nvimopen
    return
  fi

  if [ "$1" = "-cd" ] || [ "$1" = "cd" ]; then
    # cd $base_dir
    # if no second argument is provided, cd to the base directory
    if [ -z "$2" ]; then
      cd $base_dir
    else
      # find the substring in the base directory
      substring=$(grep -i "$2" ~/.hw.txt)
      if [ -z "$substring" ]; then
        echo "No substring found"
        substring_list=$(cat ~/.hw.txt)
        choose
      fi
      # if there's more than one match print them all
      # and prompt the user to choose one
      if [ $(echo "$substring" | wc -l) -gt 1 ]; then
        echo "Multiple substrings found:"
        substring_list=$substring
        choose
      fi
      # Assuming the filename can be directly inferred from substring, adjust as needed
      sub="${base_dir}/${substring}/"
      if [ -d "$sub" ]; then
        cd "$sub"
      else
        echo "Erorr with 1=cd: Directory does not exist: $sub"
      fi
    fi
    return
  fi

  if [ "$1" = "brr" ]; then
    server $1
    return
  fi

  if [ "$1" = "grr" ]; then
    server $1
    return
  fi

  if [ "$1" = "ml" ]; then
    cd $mlnotes
    filename="content.tex"
    nvimopen
    return
  fi

  # if $1 is empty, prompt the user to choose 
  # the substring out of all possible options from .hw.txt
  # if -c is provided, create a new homework folder
  # otherwise, search for the substring in .hw.txt
  
  echo "First argument: $1"
  echo "Second argument: $2"
  echo "Third argument: $3"
  # if no argument or -c but no number is provided,
  if [ -z "$1" ]; then
    substring_list=$(cat ~/.hw.txt)
    choose
  elif [ "$1" = "-c" ] && [ -z "$2" ]; then
    substring_list=$(cat ~/.hw.txt)
    choose
  elif [ "$1" = "c" ] && [ -z "$2" ]; then
    substring_list=$(cat ~/.hw.txt)
    choose
  elif [ "$1" = "-c" ] || [ "$1" = "c" ]; then
    substring=$(grep -i "$2" ~/.hw.txt)
  else
    substring=$(grep -i "$1" ~/.hw.txt)
  fi
  
  # If the substring is not found, exit
  if [ -z "$substring" ]; then
      echo "No substring found"
      substring_list=$(cat ~/.hw.txt)
      choose
  fi
  # if there's more than one match print them all
  # and prompt the user to choose one
  # 
  if [ $(echo "$substring" | wc -l) -gt 1 ]; then
    echo "Multiple substrings found:"
    substring_list=$substring
    choose
  fi
  # Assuming the filename can be directly inferred from substring, adjust as needed
  sub="${base_dir}/${substring}/"
  if [ -d "$sub" ]; then
    cd "$sub"
    if [ ! -d "hw" ]; then
      mkdir hw
    fi
    cd hw
  else
    echo "Error no course folder: Directory does not exist: $sub"
  fi

  cd "$full_path"
  
  # Out of all the homweork folders in the form of "hw1", "hw2", etc., open the latest one
  latest_hw=$(ls -d hw* | sort -n | tail -n 1)

  # if there are no homework folders,
  # and the first argument is not -c, exit
  
  filename="content.tex"

  # if latest_hw = hw
  if [ "$latest_hw" = "hw" ]; then
    echo "No homework folders found"
    newfolder
  fi

  if [ -z "$latest_hw" ] && [ "$1" != "-c" ]; then
    echo "No homework folders found"
    newfolder
  fi

  if [ "$1" = "-c" ] || [ "$1" = "c" ]; then
    newfolder
    return
  fi

  # if there is no argument -c, but there is an argument $2, 
  # open the homework with that number
  if [ ! -z "$2" ] && [ "$1" != "-c" ] ; then
    latest_hw=$(printf "hw%02d" $2)
  fi
  # check if the folder exists
  if [ ! -d "$latest_hw" ]; then
    echo "Error no latest homework folder: Directory does not exist: $latest_hw"
    return
  fi

  echo "Opening homework folder: $latest_hw"
  cd "$latest_hw"

  # Check if the file exists
  if [ ! -f "$filename" ]; then
      echo "File does not exist: $filename"
      return
  fi

  # Open the file in neovim with the necessary commands
  nvimopen 
}
