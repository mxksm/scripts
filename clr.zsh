calculate_ratios() {
  local r=$1
  local g=$2
  local b=$3
  #printf "%.6f" $(echo "$r / 256" | bc -l)
  #printf " %.6f" $(echo "$g / 256" | bc -l)
  #printf " %.6f\n" $(echo "$b / 256" | bc -l)
  pbcopy <<< "$(printf "%.4f %.4f %.4f" $(echo "$r / 256" | bc -l) $(echo "$g / 256" | bc -l) $(echo "$b / 256" | bc -l))"
}

clr() {
  # Check input format
  if [[ $1 =~ ^([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$ ]]; then
    hex=$1
    if [[ ${#hex} -eq 3 ]]; then
        # Expand shorthand hex (#RGB to #RRGGBB)
        r=${hex:0:1}${hex:0:1}
        g=${hex:1:1}${hex:1:1}
        b=${hex:2:1}${hex:2:1}
    else
        # Standard hex
        r=${hex:0:2}
        g=${hex:2:2}
        b=${hex:4:2}
    fi

    r=$((16#$r))
    g=$((16#$g))
    b=$((16#$b))

    calculate_ratios $r $g $b
  elif [[ $# -eq 3 ]]; then
    # RGB values as arguments
    r=$1
    g=$2
    b=$3
    if [[ $r -ge 0 && $r -le 255 && $g -ge 0 && $g -le 255 && $b -ge 0 && $b -le 255 ]]; then
      calculate_ratios $r $g $b
    else
      echo "Error: RGB values must be integers between 0 and 255."
    fi
  else
    echo "Usage: $0 #hexcode or $0 R G B"
    echo "Example with hex: $0 #25A3FF"
    echo "Example with RGB: $0 37 66 123"
  fi
}
