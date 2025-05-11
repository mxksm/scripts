create_new_hw_folder() {
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
  open_file_with_nvim
  return
}

choose_course() {
  # Lists directories (courses) and lets the user choose_course one
  echo "Courses:"
  i=1
  while IFS= read -r line; do
    echo "$i: $line"
    i=$((i+1))
  done <<< "$course_list"

  echo "Choose one:"
  read user_choice

  while ! [[ $user_choice =~ ^[0-9]+$ ]]; do
    echo "Not a number"
    # exit compeltely out of bash, not just this function
    echo "Choose one:"
    read user_choice
  done

  chosen_course=$(echo "$course_list" | sed -n "${user_choice}p")
  echo "Chosen course: $chosen_course"
  course="$chosen_course"
}

open_file_with_nvim() {
  # if file named 3 exists, remove it
  if [ -f "3" ]; then
    rm 3
  fi

  if [ ! -f "$filename" ]; then
    filename="main.tex"
  fi

  if [ ! -f "$filename" ] || [ $last_argument = "typst" ]; then
    if [ -f "main.typ" ]; then 
      filename="main.typ"
    else
      echo "File does not exist: $filename"
      return
    fi
    # if filename is of type .typ, open it with another command
    nvim "$filename" \
        -c ':lua require("nvterm.terminal").send("typst watch main.typ", "horizontal")' \
        -c ':lua vim.fn.jobstart({"zsh", "-c", "source ~/.zshrc && pdf main"}, {detach = true})' 

    return
  fi

  nvim "$filename" \
      -c ':set filetype=tex' \
      -c ':VimtexCompile' \
      -c ':bnext'
}

work() {
  semester_path=~/Documents/university/3_year/2_semester
  if [ -f "3" ]; then
    rm 3
  fi

  last_argument="${@:$#}"

  if [ "$1" = "-h" ]; then
    filename="content.tex"
    open_file_with_nvim
    return
  fi

  if [ "$1" = "-hm" ]; then
    filename="main.tex"
    open_file_with_nvim
    return
  fi

  if [ "$1" = "-r" ]; then
    cd ~/Documents/resume/
    filename="resume.tex"
    open_file_with_nvim
    return
  fi

  if [ "$1" = "-grr" ]; then
    ssh mlavrenk@data.cs.purdue.edu
    return
  fi

  if [ "$1" = "-cd" ]; then
    if [ -z "$2" ]; then
      cd $semester_path
    else
      course_list=$(ls -1 $semester_path | grep -v '^TA-')
      course=$(echo "$course_list" | grep -i "$2")

      if [ -z "$course" ]; then
        echo "No course found"
        course_list=$(ls -1 $semester_path | grep -v '^TA-')
        choose_course
      fi

      if [ $(echo "$course" | wc -l) -gt 1 ]; then
        echo "Multiple courses found:"
        course_list="$course"
        choose_course
        course="$chosen_course"
      fi

      course_path="${semester_path}/${course}/"
      if [ -d "$course_path" ]; then
        cd "$course_path"
      else
        echo "Error with 1=cd: Directory does not exist: $course_path"
      fi

      # now use $3, $4, ..., $n as course_pathfolders
      if [ ! -z "$3" ]; then
        course_path="${semester_path}/${course}"
        for arg in "${@:3}"; do
          course_path="${course_path}/$arg"
        done
        if [ -d "$course_path" ]; then
          cd "$course_path"
        else
          echo "Error with 2=cd: Directory does not exist: $course_path"
        fi
      fi
    fi
    return
  fi

  # When listing courses, exclude any that start with TA-
  if [ -z "$1" ]; then
    course_list=$(ls -1 $semester_path | grep -v '^TA-')
    choose_course
  elif [ "$1" = "-c" ] && [ -z "$2" ]; then
    course_list=$(ls -1 $semester_path | grep -v '^TA-')
    choose_course
  elif [ "$1" = "c" ] && [ -z "$2" ]; then
    course_list=$(ls -1 $semester_path | grep -v '^TA-')
    choose_course
  elif [ "$1" = "-c" ] || [ "$1" = "c" ]; then
    course_list=$(ls -1 $semester_path | grep -v '^TA-')
    course=$(echo "$course_list" | grep -i "$2")
  else
    course_list=$(ls -1 $semester_path | grep -v '^TA-')
    course=$(echo "$course_list" | grep -i "$1")
  fi
  
  if [ -z "$course" ]; then
    echo "No course found"
    course_list=$(ls -1 $semester_path | grep -v '^TA-')
    choose_course
    course="$chosen_course"
  fi

  if [ $(echo "$course" | wc -l) -gt 1 ]; then
    echo "Multiple courses found:"
    course_list="$course"
    choose_course
    course="$chosen_course"
  fi

  course_path="${semester_path}/${course}/"
#  # if the last argument is notes, go to the course and open notes directory instead
  if [ "$2" = "-notes" ] || [ "$2" = "-n" ]; then
    notes="${course}-notes"
    if [ -d "$course_path" ]; then
      cd "$course_path"
      if [ ! -d "$notes" ]; then
        mkdir "$notes"
        echo "Error: open the vault inside Obsidian, it requires you to open it there the first time"
        return
      fi
      cd "$notes"
    else
      echo "Error no course folder: Directory does not exist: $course_path"
      return
    fi
    obsidian "$notes"
    # if error occurs,
    if [ $? -ne 0 ]; then
      echo "Error: open the vault inside Obsidian, it requires you to open it there the first time"
      return
    fi

    return
  fi

  if [ -d "$course_path" ]; then
    cd "$course_path"
    if [ ! -d "hw" ]; then
      mkdir hw
    fi
    cd hw
  else
    echo "Error no course folder: Directory does not exist: $course_path"
    return
  fi

  latest_hw=$(ls -d hw* 2>/dev/null | sort -n | tail -n 1)

  filename="content.tex"

  if [ "$latest_hw" = "hw" ]; then
    echo "No homework folders found"
    create_new_hw_folder
  fi

  if [ -z "$latest_hw" ] && [ "$1" != "-c" ]; then
    echo "No homework folders found"
    create_new_hw_folder
  fi

  if [ "$1" = "-c" ] || [ "$1" = "c" ]; then
    create_new_hw_folder
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

  open_file_with_nvim
}
