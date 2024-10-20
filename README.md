# MATLAB Scripts for Walking Asymmetry and Endpoint Control Analysis

## Overview

This repository contains MATLAB scripts that were developed for analyzing walking asymmetry and endpoint control in stroke survivors, as detailed in our paper *Monitoring Walking Asymmetries and Endpoint Control in Persons Living with Chronic Stroke* by Song and Hardin (2024). The scripts are designed to process motion capture data, calculate metrics such as mediolateral displacement (MLD), and analyze pelvic-foot coupling. 

## MATLAB Scripts

### 1. SectionDataProcessorV7.m
   - **Purpose**: Processes motion data sections from walking trials to calculate key walking parameters such as mediolateral displacement (MLD) and pelvic displacement.
   - **Inputs**: Raw motion capture data.
   - **Outputs**: Processed MLD and variability metrics for each trial.

### 2. xCoMExtrapolationandxcorr.m
   - **Purpose**: Calculates the extrapolated center of mass (XCoM) and performs cross-correlation analysis between foot and center of mass (CoM) movement to investigate dynamic balance and stability.
   - **Inputs**: Time-synchronized motion capture data of foot and CoM.
   - **Outputs**: Maximum cross-correlation value (xCorr) and time lag (tLag) between the foot and XCoM for each trial.

### 3. SubjectXcorrDataProcessor.m
   - **Purpose**: Processes subject-specific cross-correlation data to identify patterns in the coordination between the foot and the XCoM during walking.
   - **Inputs**: Subject-specific motion capture data.
   - **Outputs**: Summary of cross-correlation and time lag metrics for each subject.

### 4. Spectrum.m
   - **Purpose**: Performs spectral analysis on walking data to investigate frequency components related to walking asymmetries and compensatory movements.
   - **Inputs**: Processed walking data from motion capture trials.
   - **Outputs**: Frequency domain analysis of walking asymmetries.

### 5. LLMSectionDataProcessor.m
   - **Purpose**: Processes lateral movement data to quantify lateral pelvic displacement and the coupling with lower limb movements.
   - **Inputs**: Raw lateral motion capture data.
   - **Outputs**: Processed lateral movement data and coupling strength metrics.

### 6. CreateSubjectFolders.m
   - **Purpose**: Automates the creation of subject-specific folders for organizing walking data and analysis results.
   - **Inputs**: Subject IDs and raw motion capture data.
   - **Outputs**: Structured folders containing processed data for each subject.

## Data Requirements

The scripts require raw motion capture data collected at a sampling frequency of 100 Hz using standard sensors placed at specific anatomical landmarks (e.g., pelvis and lateral malleoli). Ensure that data is properly formatted before using the scripts.

## How to Use

1. **Prepare Data**: Ensure that motion capture data is organized in the required format with time-synchronized data for foot and CoM movements.
2. **Run Scripts**: Execute the scripts in MATLAB to process the data and compute walking asymmetry and control metrics.
   - Start with `CreateSubjectFolders.m` to organize subject data.
   - Use `SectionDataProcessorV7.m` and `LLMSectionDataProcessor.m` to preprocess and extract key metrics.
   - For cross-correlation analysis, use `xCoMExtrapolationandxcorr.m` and `SubjectXcorrDataProcessor.m`.
   - Run `Spectrum.m` for spectral analysis if needed.

## Citation

If you use these scripts or the methodologies described in our paper, please cite the following:

> Song, J., & Hardin, E. C. (2024). *Monitoring Walking Asymmetries and Endpoint Control in Persons Living with Chronic Stroke: Implications for Remote Diagnosis and Telerehabilitation*. Digital Health Journal.

