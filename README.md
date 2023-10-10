This repository contains a collection of custom scripts made by me during some projects in which I worked. They are written so that they can be integrated into the Brainstorm toolbox, which increases their usability by non-programmers.

Brainstorm is a toolbox written in Matlab for analysis of brain recordings including, but not limited to MEG, EEG, fNIRS, ECoG, etc. In the context of Electrical Source Imaging, Brainstorm offers integrations with state-of-the-art toolboxes such as CAT12 for processing anatomical MRI data, and OPENMEEG for solving the forward problems of EEG vs electrical dipoles.

# Setup

In order to run these scripts, make sure to have a working installation of [Brainstorm](https://neuroimage.usc.edu/brainstorm/Installation). 

Take note of the location of the folder `~/.brainstorm/process`; this is for user-defined processes. Copy the provided file `process_(...).m` to that folder, then run Brainstorm as usual. 

Information on usage is specific to each function.

# Script 1: Automatic electrode location

This script determines the locations of either a rectangular grid of surface electrodes, or depth electrodes on a stylet. The protocol for this is to locate the Central Line and Anterior Edge, then locate electrodes based on that information, taking into account the curvature of the surface.

<img src="script1_ElectrodeLocation/img/diagramGrid1.png" width="295" height="500">

- **Input:**
  - Surface of the brain cortex.
  - Protocol for placing electrodes.

- **Output:**
  - Electrode locations

The brain cortex surface was extracted from a publicly available MRI template, published by Norris et al. 
Extraction was performed using the CAT toolbox, running within the Brainstorm toolbox.
The resulting data was exported as 'cortex.mat'.

The protocol for placing the electrodes is as follows:
1. Identify Central Line.
2. Identify Anterior Edge.
3. Create a line parallel to the Central Line, separated by 10 mm from it.
4. Starting at 10 mm from the Anterior Edge, place ECoG electrodes with 10 mm center-to-center.
5. Identify the point between electrodes 2 and 3 as the Entry Point for stylet.
6. Use superior-inferior as the direction of the stylet.
7. Starting at 10 mm from the entry point, place Deep Electrodes with 5 mm center-to-center.

<img src="script1_ElectrodeLocation/img/electrodes_lines.png" width="500" height="218">

I want to rewrite this script as a Brainstorm-readable function in future versions.

## References
MRI brain templates of the male Yucatan minipig (2021) Norris C, Lisinski J, McNeil E, et al. NeuroImage. DOI: 10.1016/j.neuroimage.2021.118015

# Script 2: Estimate Deep Electrode Recordings via Electrical Source Imaging

Once the Wiener Kernel or Full Inverse Solution is computed, such data is used to simulate the recordings that could be obtained from Deep Electrodes.
For each intended depth electrode, a scout is created with the dipoles located within some given distance. These dipoles are averaged over each canonical direction, and then the magnitude is extracted.

This script was intended for a paper in which the data from these Estimated Deep Electrodes was compared to that of real Deep Electrodes.

<img src="script2_EstimateDeepElectrodes/img/basic_idea.png" width="429" height="400">


## Usage

After doing the inverse model (cite from Brainstorm page), select to Process -> Souces -> .
