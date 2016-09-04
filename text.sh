#!/bin/bash

# Text to process
if [ -z "$1" ]
  then
    read -p $'Enter text and press <Enter>\n' text
	else
		name=$1
		dirname="text_$name"
		inputparameters=$dirname/$name'_INPUT-parameters.txt'
		text=$(sed -n '1p' < $inputparameters | cut -d "=" -f 2)
fi

# Input (first run only--script will use saved parameters in file if one exists)
size=200
scale=13
startx=200
starty=200
n=2

# Output
name=${text:0:10}
name=${name// /_}
if [ -z "$name" ]; then exit 1; fi
dirname="text_$name"
[ -d "$dirname" ] || mkdir "$dirname"
image=$dirname/$name'.png'
output=$dirname/$name'_1-processed.png'
pixels=$dirname/$name'_2-black-pixels.txt'
coord=$dirname/$name'_3-coord.txt'

# Save/load input parameters
inputparameters=$dirname/$name'_INPUT-parameters.txt'
if [ -f "$inputparameters" ]
	then
		# Load
		size=$(sed -n '2p' < $inputparameters | cut -d "=" -f 2)
		scale=$(sed -n '3p' < $inputparameters | cut -d "=" -f 2)
		startx=$(sed -n '4p' < $inputparameters | cut -d "=" -f 2)
		starty=$(sed -n '5p' < $inputparameters | cut -d "=" -f 2)
		n=$(sed -n '6p' < $inputparameters | cut -d "=" -f 2)
	else
		# Save
		echo "text=$text" >> $inputparameters
		echo "size=$size" >> $inputparameters
		echo "scale=$scale" >> $inputparameters
		echo "startx=$startx" >> $inputparameters
		echo "starty=$starty" >> $inputparameters
		echo "n=$n" >> $inputparameters
fi

echo "Converting to coordinates..."

convert -background white -fill black \
  -pointsize 72 label:"$text" \
	$image

[ -f "$image" ] || exit 1

# Identify original image size
originalx=$(identify $image | cut -d " " -f 3 | cut -d "x" -f 1)
originaly=$(identify $image | cut -d " " -f 3 | cut -d "x" -f 2)

# Convert to black pixels on white background
convert $image \
	-resize $size'x'$size \
	-fuzz 50% -fill '#bdbdbd' -opaque black \
	-colorspace Gray -ordered-dither o$n'x'$n $output

# Save pixels to text file
convert $output $pixels

# Remove white pixels
sed -i '/(255,255,255)/d' $pixels

# Save only pixel locations
sed -i 's/:.*//' $pixels

# Remove header
sed -i -e "1d" $pixels

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
done <$pixels

echo "Simulating plants..."

python test_I2P_results.py $coord

echo "Done."
