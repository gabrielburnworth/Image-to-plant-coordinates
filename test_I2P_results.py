import sys
import matplotlib.pyplot as plt
import numpy as np

# Get coordinate file to process
try:
    filename = sys.argv[1]
except IndexError:
    filename = "farmbot_3-coord.txt"

name = filename.rsplit('.', 1)[0]

# Import coordinates
try:
    x, y = np.genfromtxt(filename, delimiter=",", unpack=True)
except IOError:
    print "File: {} not found.\nTry running `bash I2P.sh`".format(filename)
    sys.exit()

# Plant sizes for simulating plant-rendered image over time
stages = [1, 2, 3, 5, 8]

for stage in stages:

    plt.close("all")

    # Add soil
    plt.plot([0, 3000], [750, 750], '-', lw=1000, color='#8a6e45')

    # Add plants
    plt.plot(x, y, 'o', mfc='#274e13', mec='#274e13', ms=stage)

    # Restrict to FarmBot bed size
    plt.xlim(0, 3000)
    plt.ylim(0, 1500)
    plt.tick_params(axis='both', which='major', labelsize=10)

    plt.axes().set_aspect('equal')
    plt.savefig("{}_simulated_stage-{:02d}".format(name, stage),
                bbox_inches='tight', dpi=200)
