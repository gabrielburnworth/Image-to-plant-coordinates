#!/bin/bash

echo
echo "Image to Plant Coordinate Converter"
echo "-----------------------------------"

# Help text
if [ "$1" == "-h" -o "$1" == "--help" ] ; then
  echo "Usage: $0 <image filename>"
  echo "  Use default image farmbot.png: $0"
  echo "  Use image.png: $0 image.png"
  exit 0
fi

# Check for correct number of arguments
if [ ! $# -lt 2 ]
  then
    echo "Too many arguments supplied."
    echo "Try enclosing the image filename in quotes."
    exit 1
fi

# Image to process
if [ -z "$1" ] # no argument
  then
    image=farmbot.png # load default image
  else
    image=${1// /_} # remove spaces in name
    if [ ! -f "$1" ] && [ ! -f "$image" ]; then echo "$1 does not exist."; exit 1; fi # verify that image exists
    [ ! -f "$1" ] || [ "$1" = $image ] || mv "$1" $image  # rename without spaces if spaces exist and not done already
    if [ ! "$1" = $image ]; then echo "Image renamed to $image"; fi # Inform that image was renamed
fi

# Output
name=$(echo $image | cut -d '.' -f 1) # Name is image filename without extension(s)
if [ -z "$name" ]; then exit 1; fi # if name is blank, exit
dirname="$name"
[ -d "$dirname" ] || mkdir "$dirname" # if directory doesn't exist, create it
trimmed=$dirname/$name'_0-trimmed.png'
output=$dirname/$name'_1-processed.png'
text=$dirname/$name'_2-black-pixels.txt'
coord=$dirname/$name'_3-coord.txt'
inputparameters=$dirname/$name'_INPUT-parameters.txt'

# Input parameters
echo
echo "INPUT PARAMETERS for $image:"
echo "-----------------------------------------------------------------"
echo " s: save and run | r: reset to defaults | q: quit without saving"
echo "-----------------------------------------------------------------"

default_parameters()
{
  size=200
  scale=13
  startx=200
  starty=200
  n=2
}

load_parameters ()
{
  size=$(sed -n '2p' < $inputparameters | cut -d "=" -f 2)
  scale=$(sed -n '3p' < $inputparameters | cut -d "=" -f 2)
  startx=$(sed -n '4p' < $inputparameters | cut -d "=" -f 2)
  starty=$(sed -n '5p' < $inputparameters | cut -d "=" -f 2)
  n=$(sed -n '6p' < $inputparameters | cut -d "=" -f 2)
}

save_parameters ()
{
  echo "# input parameters for $image" >> $inputparameters
  echo "size=$size" >> $inputparameters
  echo "scale=$scale" >> $inputparameters
  echo "startx=$startx" >> $inputparameters
  echo "starty=$starty" >> $inputparameters
  echo "n=$n" >> $inputparameters
}

input_parameters ()
{ # Save/load input parameters
  if [ -f "$inputparameters" ] # parameter file exists
    then
      load_parameters
    else
      default_parameters
      save_parameters
  fi
  print_parameters
}

print_parameters ()
{
  echo " i: size=$size"
  echo " c: scale=$scale"
  echo " x: startx=$startx"
  echo " y: starty=$starty"
  echo " n: n=$n"
  echo
}

overwrite_printed_parameters ()
{
  for i in `seq 1 7`; do
    tput cuu 1
    tput el
  done
  print_parameters
}

input_parameters

input_screen=1
while [ $input_screen -eq 1 ]; do
  read -p ">" -n 1 -r
  case "$REPLY" in
    r) # reset parameters
      echo
      default_parameters
      overwrite_printed_parameters
      ;;
    i)
      echo -ne "\e[0K\r"
      read -p "size=" size
      overwrite_printed_parameters
      ;;
    c)
      echo -ne "\e[0K\r"
      read -p "scale=" scale
      overwrite_printed_parameters
      ;;
    x)
      echo -ne "\e[0K\r"
      read -p "startx=" startx
      overwrite_printed_parameters
      ;;
    y)
      echo -ne "\e[0K\r"
      read -p "starty=" starty
      overwrite_printed_parameters
      ;;
    n)
      echo -ne "\e[0K\r"
      read -p "n=" n
      overwrite_printed_parameters
      ;;
    s) # Save input parameters to file (overwrite)
      echo -e "\e[0K\rSaving..."
      > $inputparameters
      save_parameters
      input_screen=0
      ;;
    q)
      echo -e "\e[0K\rExiting..."
      exit 0
  esac
done

# Identify original image size
originalx=$(identify $image | cut -d " " -f 3 | cut -d "x" -f 1)
originaly=$(identify $image | cut -d " " -f 3 | cut -d "x" -f 2)

echo "Converting to coordinates..."

# Trim image
convert $image -background white -flatten -trim +repage \
  -resize $originalx'x'$originaly $trimmed

# Convert to black pixels on white background
convert $trimmed \
  -resize $size'x'$size \
  -fuzz 50% -fill '#bdbdbd' -opaque black \
  -colorspace Gray -ordered-dither o$n'x'$n $output

# Save pixels to text file
convert $output $text

# Remove white pixels
sed -i '/(255,255,255)/d' $text

# Save only pixel locations
sed -i 's/:.*//' $text

# Remove header
sed -i -e "1d" $text

# Create blank coordinate output file (or clear existing)
> $coord

# Get image height
ymax=$(identify $output | cut -d " " -f 3 | cut -d "x" -f 2)

# Resize to original size
convert $output -scale $originalx'x'$originaly $output

# Convert to coordinates
while read p; do
  x=$(echo $p | cut -d ',' -f 1)
  y=$(echo $p | cut -d ',' -f 2)
  xp=$(( x ))
  yp=$(( ymax - y )) # flip right-side-up
  xh=$(( startx + xp * scale ))
  yh=$(( starty + yp * scale ))
  echo "$xh,$yh" >> $coord
done <$text

count=$(cat $coord | wc -l)
echo "$count plant coordinates generated."

echo "Simulating plants..."
python test_I2P_results.py $coord

echo "Optimizing coordinate path..."
python path_optimization.py $coord

echo
echo "Output saved in '$dirname/'."
echo "If desired, run again with '$0 $image'"
echo
