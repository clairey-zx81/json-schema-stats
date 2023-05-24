#! /usr/bin/env python

import csv
import sys
import matplotlib.pyplot as plt

SIZE = []
NB = []
file = sys.argv[1]

with open(file + ".csv") as f:
    reader = csv.reader(f, delimiter=",")
    for row in reader:
       SIZE.append(int(row[0]))
       NB.append(int(row[1]))

fig, ax = plt.subplots(figsize=(4, 2), layout='constrained')

# plt.xlabel('log2 file size')
# plt.ylabel('count')
plt.bar(SIZE, NB, color ='maroon')
plt.savefig(file + ".png", bbox_inches='tight')
