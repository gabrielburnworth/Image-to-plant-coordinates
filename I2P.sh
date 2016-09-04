#!/bin/bash

echo "Image to Plant Coordinate Converter"
echo "-----------------------------------"

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
    if [ ! -f "$1" ]; then echo "$1 does not exist."; exit 1; fi # verify that image exists
    image=${1// /_} # remove spaces in name
    [ ! -f "$1" ] || [ "$1" = $image ] || mv "$1" $image  # rename without spaces if spaces exist and not done already
    if [ ! "$1" = $image ]; then echo "Image renamed to $image"; fi # Inform that image was renamed
fi

echo "Image to convert: $image"

# Input (first run only--script will use saved parameters in file if one exists)
size=200
scale=13
startx=200
starty=200
n=2

# Output
name=$(echo $image | cut -d '.' -f 1) # Name is image filename without extension(s)
if [ -z "$name" ]; then exit 1; fi # if name is blank, exit
dirname="$name"
[ -d "$dirname" ] || mkdir "$dirname" # if directory doesn't exist, create it
trimmed=$dirname/$name'_0-trimmed.png'
output=$dirname/$name'_1-processed.png'
text=$dirname/$name'_2-black-pixels.txt'
coord=$dirname/$name'_3-coord.txt'

# Save/load input parameters
inputparameters=$dirname/$name'_INPUT-parameters.txt'
if [ -f "$inputparameters" ] # parameter file exists
  then
    # Load
    size=$(sed -n '2p' < $inputparameters | cut -d "=" -f 2)
    scale=$(sed -n '3p' < $inputparameters | cut -d "=" -f 2)
    startx=$(sed -n '4p' < $inputparameters | cut -d "=" -f 2)
    starty=$(sed -n '5p' < $inputparameters | cut -d "=" -f 2)
    n=$(sed -n '6p' < $inputparameters | cut -d "=" -f 2)
  else
    # Save
    echo "# input parameters for $image" >> $inputparameters
    echo "size=$size" >> $inputparameters
    echo "scale=$scale" >> $inputparameters
    echo "startx=$startx" >> $inputparameters
    echo "starty=$starty" >> $inputparameters
    echo "n=$n" >> $inputparameters
fi

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

echo "Done."
