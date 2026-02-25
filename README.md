# MEA-LoDA Method Code

Custom MATLAB code for MEA (multi-electrode array) signal analysis used in the manuscript on LoDA-Based MEA Workflow for Neuronal Network Burst Analysis

## Overview

This repository contains in-house MATLAB scripts for processing and analyzing MEA recordings, including:

- LoDA signal generation
- Synchrony analysis (well-level and channel-level)
- Network burst period (NBP) detection
- Stacked waveform generation and waveform feature extraction
- Network burst spatiotemporal (NBST) analysis
- Figure-specific plotting scripts used for manuscript figures

The repository also includes example/analysis input data (`data/`), saved analysis outputs (`results/`), and exported figure files (`figures/`) corresponding to the manuscript workflow.

## MATLAB version

All analyses were conducted using custom MATLAB scripts developed in-house and tested in:

- **MATLAB R2023b**

## Repository structure

```text
MEA-LoDA_Method_Code/
├── data/                 # Input datasets used for analysis scripts (.mat)
│   ├── data_dev.mat
│   ├── data_stim_pre.mat
│   └── data_stim_post.mat
├── results/              # Saved intermediate / final analysis outputs (.mat)
├── figures/              # Exported manuscript figures (.tif)
├── scripts/              # Analysis and plotting scripts (main runnable scripts)
├── src/
│   ├── LoDA_sync/        # Core functions for LoDA and synchrony analysis
│   ├── NBP/              # Functions for network-burst-period and NBST analysis
│   └── visualization/    # Plotting helper functions
├── docs/                 # Optional documentation (currently empty)
└── resources/project/    # MATLAB project metadata
