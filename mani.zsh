mani() {
  # if there's no arguments, just run manim main.py
  # otherwise, use all arguments as the manim command
  
#  rm -rf media

  if [ "$1" ]; then
    # if the last possible argument is not a .py file, add main.py
    if [[ ! "${@: -1}" =~ \.py$ ]]; then
      set -- "$@" main.py
    fi
    # then, just call manim with all arguments
    manim "$@"
  else
    manim main.py
  fi

  # if latest folder does not exist, symbolic link media/
  # ln -s media/videos/main/1080p60 latest
  latest='media'
  if [ ! -d $latest ]; then
    echo "$latest/ does not exist"
    return 1
  fi

  # Find the most recently modified file in the latest directory (including subdirectories)
#  latest_file=$(find $latest -type f \( -name "*.mp4" -o -name "*.png" \) -exec stat -f "%m %N" {} \; | sort -n -r | head -n 1 | cut -d' ' -f2-)
    # Find the most recently modified file in the latest directory (excluding partial_movie_files)
  latest_file=$(find $latest -type f \( -name "*.mp4" -o -name "*.png" \) \
    -not -path "*/partial_movie_files/*" \
    -exec stat -f "%m %N" {} \; | sort -n -r | head -n 1 | cut -d' ' -f2-)

  echo "Latest file: $latest_file"

  # if it doesn't end with mp4 or png, return 1
  if [[ ! $latest_file =~ \.mp4$ && ! $latest_file =~ \.png$ ]]; then
    echo "Latest file is not an mp4 or png file"
    return 1
  fi
  
  # Play it with mpv
  if [ -n "$latest_file" ]; then
      mpv "$latest_file"
  else
      echo "No file found in $latest/"
  fi
}

