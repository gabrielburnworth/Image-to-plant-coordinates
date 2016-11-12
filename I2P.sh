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
echo " h: help text" #    | w: install dependencies (Debian)
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
  read -sp ">" -n 1 -r
  case "$REPLY" in
    r) # reset parameters
      echo
      default_parameters
      overwrite_printed_parameters
      ;;
    i)
      echo -ne "\e[0K\r"
      read -p "size=" size
      while ! [ "$size" -eq "$size" ] 2> /dev/null
        do
          tput cuu 1
          tput el
          read -p "[Please enter an integer] size=" size
      done
      overwrite_printed_parameters
      ;;
    c)
      echo -ne "\e[0K\r"
      read -p "scale=" scale
      while ! [ "$scale" -eq "$scale" ] 2> /dev/null
        do
          tput cuu 1
          tput el
          read -p "[Please enter an integer] scale=" scale
      done
      overwrite_printed_parameters
      ;;
    x)
      echo -ne "\e[0K\r"
      read -p "startx=" startx
      while ! [ "$startx" -eq "$startx" ] 2> /dev/null
        do
          tput cuu 1
          tput el
          read -p "[Please enter an integer] startx=" startx
      done
      overwrite_printed_parameters
      ;;
    y)
      echo -ne "\e[0K\r"
      read -p "starty=" starty
      while ! [ "$starty" -eq "$starty" ] 2> /dev/null
        do
          tput cuu 1
          tput el
          read -p "[Please enter an integer] starty=" starty
      done
      overwrite_printed_parameters
      ;;
    n)
      echo -ne "\e[0K\r"
      read -p "n=" n
      while ! [ "$n" -eq 2 -o "$n" -eq 3 -o "$n" -eq 4 -o "$n" -eq 8 ] 2> /dev/null
        do
          tput cuu 1
          tput el
          read -p "[Please enter 2, 3, 4, or 8] n=" n
      done
      overwrite_printed_parameters
      ;;
    s) # Save input parameters to file (overwrite)
      echo -e "\e[0K\rSaving..."
      > $inputparameters
      save_parameters
      input_screen=0
      ;;
    h) # Help text
      echo -e "\e[0K\rHelp text:"
      echo -e "
VARIABLE    DEFAULT        DESCRIPTION
--------    -------        -----------
size        200            Pixel width/height used to resize the image.
                           Affects number of coordinate results.

scale       13             Scale for image rendered in plants.


startx      200            X coordinate of bottom left of plant-rendered image.


starty      200            Y coordinate of bottom left of plant-rendered image.


n           2 (2,3,4,8).   Ordered dither tiling size.
                           Affects number of coordinate results.

To install dependencies required for this program on Debian, run:
sudo apt-get install imagemagick python-numpy python-matplotlib python-scipy

"
      read -p "Press <Enter> to continue..."
      for i in `seq 1 24`; do
        tput cuu 1
        tput el
      done
      ;;
#    w) # Install dependencies
#      sudo apt-get install imagemagick python-numpy python-matplotlib python-scipy
#      ;;
    q)
      echo -e "\e[0K\rExiting..."
      exit 0
      ;;
    '')
      echo -ne "\e[0K\r"
      ;;
    *)
      echo -ne "\e[0K\r"
      ;;
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
sed -i '/(65535,65535,65535)/d' $text

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
if [ $? -eq 0 ]; then
    echo "Coordinate path optimized."
else
    tput setaf 1
    echo -e "\nERROR: Path not optimized. Perhaps scipy is not installed?\nTry running 'sudo apt-get install python-scipy' if using Debian."
    tput sgr0
fi

echo
echo "Output saved in '$dirname/'."
echo "If desired, run again with '$0 $image'"
echo
