# Image Analysis Traditional

This repository contains components for conducting image analysis in life sciences with traditional algorithms.

## Components

1. **Course Illustration Code**: The code for the course [Image Analysis in Life Science](./Image_Analysis_in_Life_Science).

2. **Image Analysis Workflow**: The workflow includes the following steps:
   - **Segment** the nucleus and heterochromatin areas from a cell.
   - **Count** the Nuclear Pore Complex (NPC) objects.
   - **Measure** the total area and average fluorescence of the regions of interest (ROI).
   - **Compare** selected variables across three time conditions: 18d, 28d, and 37d.

## Scripts

The following scripts are used for extraction and analysis:
- **Extraction**: [nucleus.ijm](./src/nucleus.ijm)
- **Analysis**: [analysis.ipynb](./src/analysis.ipynb)