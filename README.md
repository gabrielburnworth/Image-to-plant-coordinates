# Image to Plant Coordinates

Generates coordinates to grow plants in the shape of an image

## Usage

`bash I2P.sh`

## Output

#### Input:

![farmbot](https://cloud.githubusercontent.com/assets/12681652/18229154/e97b0d1c-7221-11e6-9992-f78d1b94abb7.png)


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

![simulated_stage-04](https://cloud.githubusercontent.com/assets/12681652/18229152/e96d2efe-7221-11e6-9f94-3aa0cf2bf1d9.png)


#### Simulated plant-rendered image - plants larger:

![simulated_stage-06](https://cloud.githubusercontent.com/assets/12681652/18229150/e96921d8-7221-11e6-9a7e-08ff1ae7bc25.png)


## Options

edit values in the `Input` section of `I2P.sh`

variable | default | description
 :---: | :---: | :---
`image` | farmbot.png | Input image: try dark object on a white or transparent background.
`size` | 200 | Size to resize the image. Affects number of coordinate results.
`scale` | 13 | Scale for image rendered in plants.
`startx` | 200 | X coordinate of bottom left of plant-rendered image.
`starty` | 200 | Y coordinate of bottom left of plant-rendered image.
`n` | 2 | (2-8, even). Affects number of coordinate results.
