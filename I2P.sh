#!/bin/bash

# Input
image=farmbot.png
size=200
scale=13
startx=200
starty=200
n=2

# Output
name=$(echo $image | cut -d '.' -f 1)
trimmed=$name'_0-trimmed.png'
output=$name'_1-processed.png'
text=$name'_2-black-pixels.txt'
coord=$name'_3-coord.txt'

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

echo "Simulating plants..."

python test_I2P_results.py $coord

echo "Done."
