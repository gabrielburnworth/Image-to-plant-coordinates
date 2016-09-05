# Image to Plant Coordinates

Generates coordinates to grow plants in the shape of an image using _diffused pixel ordered dithering_

## Dependencies

`sudo apt-get install imagemagick`

for simulations: `sudo apt-get install python-numpy python-matplotlib`

for path optimization: `sudo apt-get install python-scipy`

## Usage

##### Convert `farmbot.png` to plant coordinates:

`bash I2P.sh farmbot.png`

##### Adjust parameters:

Edit and save parameter values (see [options](#options)) in `farmbot_INPUT-parameters.txt` in the `farmbot` directory

Run `bash I2P.sh farmbot.png` again

## Input

![farmbot](https://cloud.githubusercontent.com/assets/12681652/18229154/e97b0d1c-7221-11e6-9992-f78d1b94abb7.png)


## Output

#### Trimmed image:

![farmbot_0-trimmed](https://cloud.githubusercontent.com/assets/12681652/18229153/e971dddc-7221-11e6-9ed6-be40529b4115.png)


#### Processed image (enlarged):

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


#### __Optimized__ plant coordinate text file (x, y) from bottom left of bed:

```
200.0,460.0
200.0,486.0
213.0,499.0
226.0,486.0
...
```

###### Optimization Method

Begin at bottom-leftmost point and travel to the nearest point.
Continue to the next closest point until all points have been reached.
Once a point has been reached, it is no longer a candidate.

![farmbot_optimization-details](https://cloud.githubusercontent.com/assets/12681652/18238909/299801be-72f6-11e6-8928-5aaba0f8e95a.png)


## Options

Run script with default values first.

Then, edit values in `*_INPUT-parameters.txt` in the directory created during script execution.
The directory name will be the input image name with spaces replaced with underscores if running `bash I2P.sh`, or 'text_' and the first 10 characters of text string with spaces replaced with underscores if running `bash text.sh`.

variable | default | description
 :---: | :---: | :---
`image` | farmbot.png | Input image: try a dark object on a white or transparent background.
`size` | 200 | Pixel width/height used to resize the image. Affects number of coordinate results.
`scale` | 13 | Scale for image rendered in plants.
`startx` | 200 | X coordinate of bottom left of plant-rendered image.
`starty` | 200 | Y coordinate of bottom left of plant-rendered image.
`n` | 2 | (2,3,4,8). Ordered dither tiling size. Affects number of coordinate results.

## Convert text

##### Convert text to plant coordinates:

`bash text.sh`

Enter text at prompt.
```
Enter text and press <Enter>
farmbot
```

![farmbot_3-coord_simulated_stage-03](https://cloud.githubusercontent.com/assets/12681652/18233267/0e02a13e-7297-11e6-889c-7171a9df4557.png)

##### Adjust parameters:

Edit and save parameter values (see [options](#options)) in `farmbot_INPUT-parameters.txt` in the `text_farmbot` directory

Run `bash text.sh farmbot`

(For other text, the directory name will be 'text_' and the first 10 characters of text string with spaces replaced with underscores. For the argument to re-run with updated parameters, use the directory name without 'text_'. You may also use `bash text.sh` and retype the text when prompted. To return to default values, delete the 'text_*' directory and run again.)
