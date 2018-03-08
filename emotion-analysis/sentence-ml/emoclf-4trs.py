import numpy as np
import scipy as sp

import matplotlib.pyplot as plt

import sklearn as sk
import nltk as tk

from sklearn.feature_extraction.text import CountVectorizer

# Filenames of transcripts
fns = ['./data/txt03_Eickman_clipped.txt',
       './data/txt04_Snep_clipped.txt',
       './data/txt05_Baron_dAulnis_clipped.txt',
       './data/txt06_Hofman_clipped.txt']

# Read clipped versions of txt
lines = []
for fn in fns:
    lines += [line.rstrip('\n') for line in open(fn, 'r')]

# Extract BoW representation
V = CountVectorizer()
X = V.fit_transform(lines).toarray()

#TODO label extraction from annotations

#TODO classifier training

#TODO prediction on new stories
