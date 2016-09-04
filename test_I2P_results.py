import sys
import matplotlib.pyplot as plt
import numpy as np

try:
    filename = sys.argv[1]
except IndexError:
    filename = "farmbot_3-coord.txt"

try:
    x, y = np.genfromtxt(filename, delimiter=",", unpack=True)
except IOError:
    print "File: {} not found.\nTry running `bash I2P.sh`".format(filename)
    sys.exit()

stages = [1, 4, 6, 10]

for stage in stages:

    plt.close("all")

    plt.plot([0, 3000], [750, 750], '-', lw=1000, color='#8a6e45')

    plt.plot(x, y, 'o', mfc='#274e13', mec='#274e13', ms=stage)

    plt.xlim(0, 3000)
    plt.ylim(0, 1500)

    plt.axes().set_aspect('equal')
    plt.tight_layout()
    plt.savefig("simulated_stage-{:02d}".format(stage), dpi=200)
