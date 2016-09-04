# Image to Plant Coordinates

Generates coordinates to grow plants in the shape of an image

## Usage

`bash I2P.sh`

## Output

farmbot_0-trimmed.png

farmbot_1-processed.png

farmbot_2-black-pixels.txt

```
90,1
92,1
94,1
96,1
...
```

farmbot_3-coord.txt

```
1370,1370
1396,1370
1422,1370
1448,1370
...
```

simulated_stage-04.png

simulated_stage-06.png

## Options

edit values in the `Input` section of `I2P.sh`

image: farmbot.png

Input image: try dark object on a white or transparent background.


size: 200

Size to resize the image. Affects number of coordinate results.


scale: 13

Scale for image rendered in plants.


startx: 200

X coordinate of bottom left of plant-rendered image.


starty: 200

Y coordinate of bottom left of plant-rendered image.

n: 2

(2-8, even). Affects number of coordinate results.
