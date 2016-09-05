#!/usr/bin/env python

"""Optimizes coordinate path

A very simple TSP solution"""

import sys
import matplotlib.pyplot as plt
import numpy as np
from scipy.spatial.distance import cdist

def path_plot_format(opt_method, axis):
    """"Add points, limits, annotation to plot."""
    x, y = original_data[:, 0], original_data[:, 1]
    axis.plot(x, y, 'o', mec='k', mfc='k') # plot points
    axis.set_xlim(0, 15000)
    axis.set_ylim(0, 5000)
    axis.set_title(opt_method, weight='extra bold', fontsize=24)
    axis.set_aspect('equal')

def closest_node(node, nodes):
    """"Return node index and node in list with
    shortest distance to input node."""
    idx = cdist([node], nodes).argmin()
    return idx, nodes[idx]

def path_length(points):
    """Calculate total length of path."""
    distance = 0
    fp = 1
    for point in points:
        if fp:
            prev_point = point
            fp = 0
        else:
            distance += np.linalg.norm(point-prev_point)
            prev_point = point
    return int(distance)

def next_closest_point(data):
    """Optimize path by chosing the closest point to the current point."""
    data_whittle = list(data)
    new_list = [data[0]]
    del data_whittle[0]

    for _ in data:
        if len(data_whittle) == 0:
            break
        current_node = np.array(new_list[-1])
        index, close_node = closest_node(current_node, data_whittle)
        new_list.append(close_node)
        del data_whittle[index]

    new_list = np.array(new_list)
    return new_list

# Get coordinate file to process
try:
    filename = sys.argv[1]
except IndexError:
    filename = "farmbot/farmbot_3-coord.txt"

try: # Name without extension and additional info
    name = filename.rsplit('.', 1)[0].split('_3')[0]
except IndexError:
    name = filename.rsplit('.', 1)[0] # Name without extension

# Import coordinates
try:
    original_data = np.genfromtxt(filename, delimiter=",")
    data_sorted_by_y = original_data
    data_sorted_by_x = original_data[np.argsort(original_data[:, 0])]
except IOError:
    print "File: {} not found.\nTry running `bash I2P.sh`".format(filename)
    sys.exit()

# Plot setup
fig = plt.figure(figsize=(52, 24))
fig.suptitle("{} ({:,} coordinates)".format(name, len(original_data)),
             weight='extra bold', fontsize=28)
grid = (7, 8)
summary = plt.subplot2grid(grid, (3, 0), colspan=8)
summary.set_yticklabels([]); summary.set_xticklabels([])

def plot_path(method, color, data, subplot, summary_index):
    ax = plt.subplot2grid(grid, subplot, rowspan=3, colspan=4) # Add subplot
    summary.barh(summary_index, path_length(data),
                 color=color, align='center') # opt summary
    summary.annotate(method, xy=(path_length(data)
                                 + summary.get_xlim()[1] / 100, summary_index),
                     ha='left', va='center', weight='bold', fontsize=18)
    summary.annotate('{:,}'.format(path_length(data)),
                     xy=(path_length(data) - summary.get_xlim()[1] / 100,
                         summary_index),
                     ha='right', va='center', weight='bold', fontsize=18,
                     color='white')
    path_plot_format(method, ax) # add common plot elements
    x, y = data[:, 0], data[:, 1]
    ax.plot(x, y, '-', color=color) # plot path
    return data

plot_path('Horizontal Raster', 'red', data_sorted_by_y, (0, 0), 0)

plot_path('Vertical Raster', 'blue', data_sorted_by_x, (0, 4), 1)

plot_path('Next closest point: vertically sorted', 'green',
             next_closest_point(data_sorted_by_y), (4, 0), 2)

op_data = plot_path('Next closest point: horizontally sorted', 'darkorange',
                       next_closest_point(data_sorted_by_x), (4, 4), 3)

# Save optimized data
np.savetxt("{}_optimized.txt".format(name), op_data, delimiter=',', fmt='%s')

# Save plot
plt.tick_params(axis='both', which='major', labelsize=10)
plt.subplots_adjust(top=1.0, hspace=0.0, wspace=0.0)
plt.savefig("{}_optimization-details".format(name),
            bbox_inches='tight', dpi=200)
