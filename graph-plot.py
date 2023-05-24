#! /usr/bin/env python

import csv
import sys
import matplotlib.pyplot as plt

NAME = []
NB = []
file = sys.argv[1]

with open(file + ".csv") as f:
    reader = csv.reader(f, delimiter=",")
    for row in reader:
       NAME.append(row[0])
       NB.append(float(row[1]))

fig, ax = plt.subplots(figsize=(8, 4), layout='constrained')

plt.xticks(rotation=45, ha="right")

# plt.xlabel('log2 file size')
# plt.ylabel('count')
plt.plot(NAME, NB, color ='blue')
plt.savefig(file + ".png", bbox_inches='tight')
