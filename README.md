# Script 1: Automatic electrode location

This project required to determine the location of ECoG electrodes (over the cortex surface) on a pig subject. While the protocol is standarized, it is relatively new in comparison with it's human counterpart.

For my project, I assume the following steps as completed using Brainstorm toolbox.
1. Download an import a template MRI for pig subjects*.
2. Segment MRI and extract cortex surface.

This script takes the cortex surface and creates a curved grid over it to place the electrodes.

On future versions, I want to rewrite this script as a Brainstorm-readable function.


# References
MRI brain templates of the male Yucatan minipig (2021) Norris C, Lisinski J, McNeil E, et al. NeuroImage. DOI: 10.1016/j.neuroimage.2021.118015
