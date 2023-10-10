This repository contains a collection of custom scripts made by me during some projects in which I worked. They are written so that they can be integrated into the Brainstorm toolbox, which increases their usability by non-programmers.

Brainstorm is a toolbox written in Matlab for analysis of brain recordings including, but not limited to MEG, EEG, fNIRS, ECoG, etc. In the context of Electrical Source Imaging, Brainstorm offers integrations with state-of-the-art toolboxes such as CAT12 for processing anatomical MRI data, and OPENMEEG for solving the forward problems of EEG vs electrical dipoles.

# Setup

In order to run these scripts, make sure to have a working installation of [Brainstorm](https://neuroimage.usc.edu/brainstorm/Installation). 

Take note of the location of the folder `~/.brainstorm/process`; this is for user-defined processes. Copy the provided file `process_(...).m` to that folder, then run Brainstorm as usual. 

Information on usage is specific to each function.

# Script 1: Automatic electrode location

This script determines the locations of either a rectangular grid of surface electrodes, or depth electrodes on a stylet. The protocol for this is to locate the Central Line and Anterior Edge, then locate electrodes based on that information, taking into account the curvature of the surface.

## For surface electrodes

**Input:**
-  `surface` Surface triangulation, `struct`.
-  `nPA`  Size of rectangle grid in the Posterior-Anterior.
-  `nLR`  Size of rectangle grid in the Left-Right direction.
-  `PA0`  Distance [mm] from the Anterior Edge to the first electrode.
-  `LR0`  Distance [mm] from the Central Line to the first electrode.
-  `dPA`  Center-to-center distance between electrodes in the Posterior-Anterior direction.
-  `dLR`  Center-to-center distance between electrodes in the Left-Rigt direction.
-  `TH` Angle with respect to a parallel to the Central Line.

**Output:**
- `ElecLocs` Locations of electrodes, (nAP)x(nLR)x3

<img src="script1_ElectrodeLocation/img/diagramGrid1.png" width="400" height="236"> <img src="script1_ElectrodeLocation/img/diagramGrid2.png" width="300" height="236">

## For inserted electrodes

**Input:**
-  `surface` Surface triangulation, `struct`.
-  `nIS`  Number of electrodes in the stylet.
-  `PA0`  Distance [mm] from the Anterior Edge to the Insertion Point.
-  `LR0`  Distance [mm] from the Central Line to the Insertion Point.
-  `IS0`  Distance [mm] from the Insertion Point to the first electrode.
-  `dIS`  Center-to-center distance between electrodes in the stylet.

**Output:**
- `ElecLocs` Locations of electrodes, (1)x(nIS)x3

<img src="script1_ElectrodeLocation/img/diagramStylet1.png" width="400" height="484"> 

## NOTES

This function was developed for a project involving animal models for ischemic stroke. Electrode positions in some animal models --such as minipig, _Sus scrofa_-- are not yet fully standardized. Thus, the electrode positions must be determined manually following some protocol.

Multiple configurations were used for training purposes. I found it easier to code the placing protocol and **then** adjust based on observations, than to determine the locations based purely on observations.

The rewriting of this function as a Brainstorm process is not finished yet.

The algrithm is quite simple: the curved lines are constructed by taking strips of the cortex surface and then using local interpolation. Distance within the curve is computed via a cumulative length function.

<img src="script1_ElectrodeLocation/img/electrodes_lines.png" width="500" height="218">

# Script 2: Estimate Deep Electrode Recordings via Electrical Source Imaging

Once the Wiener Kernel or Full Inverse Solution is computed, such data is used to simulate the recordings that could be obtained from Deep Electrodes.
For each intended depth electrode, a scout is created with the dipoles located within some given distance. These dipoles are averaged over each canonical direction, and then the magnitude is extracted.

This script was intended for a paper in which the data from these Estimated Deep Electrodes was compared to that of real Deep Electrodes.

<img src="script2_EstimateDeepElectrodes/img/basic_idea.png" width="429" height="400">


## Usage

After doing the inverse model (cite from Brainstorm page), select to Process -> Souces -> .
