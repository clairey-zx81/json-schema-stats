#! /usr/bin/env python

import csv
import sys
import matplotlib.pyplot as plt

VERSION_S = []
NB_S = []
VERSION_N = []
NB_N = []

with open("graph-version-numbers.csv") as f:
    reader = csv.reader(f, delimiter=",")
    for row in reader:
       VERSION_N.append(row[0])
       NB_N.append(int(row[1]))

with open("graph-version-simple.csv") as f:
    reader = csv.reader(f, delimiter=",")
    for row in reader:
       VERSION_S.append(row[0])
       NB_S.append(int(row[1]))

# plt.ylabel('Nb')
# A changer si necessaire
# plt.xlabel('N° version')

# Figure numbers
plt.figure(figsize = (4, 4))
plt.pie(NB_N, 
		labels=VERSION_N, 
		autopct=lambda a: str(int(round(a, 0))) + '%',
		pctdistance=1.2,
		labeldistance=None)
plt.legend(loc='upper right', bbox_to_anchor=(0.8,0.5,0.5,0.5))

plt.savefig("graph-version-numbers.png", bbox_inches='tight')
# plt.show()

# Figure simple
plt.figure(figsize = (4, 4))
plt.pie(NB_S, 
		labels=VERSION_S, 
		autopct=lambda a: str(int(round(a, 0))) + '%',
		pctdistance=1.2,
		labeldistance=None)
#plt.legend(loc='upper right')
plt.legend(loc='upper right', bbox_to_anchor=(0.8,0.5,0.5,0.5))

plt.savefig("graph-version-simple.png", bbox_inches='tight')
