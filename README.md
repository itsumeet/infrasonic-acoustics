# Animal-acoustics

This is a report on the work i did at IIT Delhi during summer internship, 2019.

Our aim is to make a model which can be used for an acoustic early warning system around the residential areas
nearby elephants populated regions and to monitor their migration patterns. I have implemented Mel frequency 
cepstral coefficients (MFCC) for feature extraction and Dynamic Time Warping (DTW) for feature matching. Using MFCC, 
cepstral coefficients are extracted from every frame of the spectrogram. Then for feature matching, DTW is used to 
find the distance between feature vectors of input audio frame and a base template frame. Depending on the Euclidean
distance calculated from DTW elephant rumbles are positively detected.
