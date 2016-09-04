# Image to Plant Coordinates

Generates coordinates to grow plants in the shape of an image using diffused pixel ordered dithering

## Dependencies

`sudo apt-get install imagemagick`

for simulations: `sudo apt-get install python-numpy python-matplotlib`

## Usage

`bash I2P.sh`

## Input

![farmbot](https://cloud.githubusercontent.com/assets/12681652/18229154/e97b0d1c-7221-11e6-9992-f78d1b94abb7.png)


## Output

#### Trimmed image:

![farmbot_0-trimmed](https://cloud.githubusercontent.com/assets/12681652/18229153/e971dddc-7221-11e6-9ed6-be40529b4115.png)


#### Processed image:

![farmbot_1-processed](https://cloud.githubusercontent.com/assets/12681652/18229151/e96aa5b2-7221-11e6-93b2-0e56ee586d42.png)


#### Black Pixel text file (x, y) from top left of image:

```
90,1
92,1
94,1
96,1
...
```

#### Plant coordinate text file (x, y) from bottom left of bed:

```
1370,1370
1396,1370
1422,1370
1448,1370
...
```

#### Simulated plant-rendered image - plants small:

![simulated_stage-03](https://cloud.githubusercontent.com/assets/12681652/18229214/09ac3d10-7225-11e6-87ec-a5304a1f40b2.png)


#### Simulated plant-rendered image - plants larger:

![simulated_stage-06](https://cloud.githubusercontent.com/assets/12681652/18229207/94f1f316-7224-11e6-8997-b901ca91b7d6.png)


## Options

edit values in the `Input` section of `I2P.sh`

variable | default | description
 :---: | :---: | :---
`image` | farmbot.png | Input image: try a dark object on a white or transparent background.
`size` | 200 | Size to resize the image. Affects number of coordinate results.
`scale` | 13 | Scale for image rendered in plants.
`startx` | 200 | X coordinate of bottom left of plant-rendered image.
`starty` | 200 | Y coordinate of bottom left of plant-rendered image.
`n` | 2 | (2,3,4,8). Ordered dither tiling size. Affects number of coordinate results.
