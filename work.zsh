
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

  mkdir "$latest_hw"
  cd "$latest_hw"

  # if the hw to create is hw01, copy the template from .template.tex
  if [[ $latest_hw = "hw01" ]]; then
    cp ~/.template.tex main.tex
  else
    # copy the main.tex from the previous homework folder
    echo "Copying main.tex from $previous_hw"
    cp "../$previous_hw/main.tex" main.tex

    # Replace the homework number in the title
    file="main.tex"
    pattern="title{.* Homework .*}"
    matched_line=$(grep -o "$pattern" "$file")

    if [ ! -z "$matched_line" ]; then
      last_number=$(echo "$matched_line" | grep -o '[0-9]\+' | tail -n 1)
      
      if [ ! -z "$last_number" ]; then
        new_number=$((last_number + 1))
        reversed_matched_line=$(echo "$matched_line" | rev)
        reversed_new_line=$(echo "$reversed_matched_line" | sed "s/$(echo $last_number | rev)/$(echo $new_number | rev)/" | rev)
        new_line=$reversed_new_line

        escaped_matched_line=$(echo "$matched_line" | sed 's/[\/&]/\\&/g')
        escaped_new_line=$(echo "$new_line" | sed 's/[\/&]/\\&/g')

        sed -i '' "s/${escaped_matched_line}/${escaped_new_line}/" "$file"
      else
        echo "No number found to increment."
      fi
    else
      echo "The pattern was not found in the file."
    fi    
  fi

  touch $filename
  pdflatex main.tex
  nvimopen
  return
}


choose() {
  # Lists directories (courses) and lets the user choose one
  echo "Courses:"
  i=1
  while IFS= read -r line; do
    echo "$i: $line"
    i=$((i+1))
  done <<< "$substring_list"

  echo "Choose one:"
  read user_choice

  if ! [[ $user_choice =~ ^[0-9]+$ ]]; then
    echo "Not a number"
    return
  fi

  chosen_course=$(echo "$substring_list" | sed -n "${user_choice}p")
  echo "Chosen substring: $chosen_course"
  substring="$chosen_course"
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
      -c ':bnext'
}



work() {
  base_dir=~/Documents/university/3_year/1_semester
  mlnotes=~/Documents/university/MLnotes

  if [ "$1" = "h" ] || [ "$1" = "-h" ]; then
    filename="content.tex"
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
    cd ~/Documents/resume/
    filename="resume.tex"
    nvimopen
    return
  fi

  if [ "$1" = "-cd" ] || [ "$1" = "cd" ]; then
    if [ -z "$2" ]; then
      cd $base_dir
    else
      substring_list=$(ls -1 $base_dir | grep -v '^TA-')
      substring=$(echo "$substring_list" | grep -i "$2")

      if [ -z "$substring" ]; then
        echo "No substring found"
        substring_list=$(ls -1 $base_dir | grep -v '^TA-')
        choose
      fi

      if [ $(echo "$substring" | wc -l) -gt 1 ]; then
        echo "Multiple substrings found:"
        substring_list="$substring"
        choose
        substring="$chosen_course"
      fi

      sub="${base_dir}/${substring}/"
      if [ -d "$sub" ]; then
        cd "$sub"
      else
        echo "Error with 1=cd: Directory does not exist: $sub"
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

  #echo "First argument: $1"
  #echo "Second argument: $2"
  #echo "Third argument: $3"

  # When listing courses, exclude any that start with TA-
  if [ -z "$1" ]; then
    substring_list=$(ls -1 $base_dir | grep -v '^TA-')
    choose
  elif [ "$1" = "-c" ] && [ -z "$2" ]; then
    substring_list=$(ls -1 $base_dir | grep -v '^TA-')
    choose
  elif [ "$1" = "c" ] && [ -z "$2" ]; then
    substring_list=$(ls -1 $base_dir | grep -v '^TA-')
    choose
  elif [ "$1" = "-c" ] || [ "$1" = "c" ]; then
    substring_list=$(ls -1 $base_dir | grep -v '^TA-')
    substring=$(echo "$substring_list" | grep -i "$2")
  else
    substring_list=$(ls -1 $base_dir | grep -v '^TA-')
    substring=$(echo "$substring_list" | grep -i "$1")
  fi
  
  if [ -z "$substring" ]; then
    echo "No substring found"
    substring_list=$(ls -1 $base_dir | grep -v '^TA-')
    choose
    substring="$chosen_course"
  fi

  if [ $(echo "$substring" | wc -l) -gt 1 ]; then
    echo "Multiple substrings found:"
    substring_list="$substring"
    choose
    substring="$chosen_course"
  fi

  sub="${base_dir}/${substring}/"
  if [ -d "$sub" ]; then
    cd "$sub"
    if [ ! -d "hw" ]; then
      mkdir hw
    fi
    cd hw
  else
    echo "Error no course folder: Directory does not exist: $sub"
    return
  fi

  cd "$PWD"

  latest_hw=$(ls -d hw* 2>/dev/null | sort -n | tail -n 1)

  filename="content.tex"

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

  if [ ! -z "$2" ] && [ "$1" != "-c" ] ; then
    latest_hw=$(printf "hw%02d" $2)
  fi

  if [ ! -d "$latest_hw" ]; then
    echo "Error no latest homework folder: Directory does not exist: $latest_hw"
    return
  fi

  echo "Opening homework folder: $latest_hw"
  cd "$latest_hw"

  if [ ! -f "$filename" ]; then
    echo "File does not exist: $filename"
    return
  fi

  nvimopen
}


