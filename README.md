# Hexagonal Sampling for Accelerated SEMAC at 0.55T

This repository contains the code and datasets for
**"Acceleration of SEMAC at 0.55T using hexagonal sampling"**, by Bahadir Alp Barlas, Kubra Keskin, Bochao Li, Brian A. Hargreaves, and Krishna S. Nayak.

Bahadir Alp Barlas, University of Southern California, May 2025.

## ISMRMRD datasets
Human and phantom datasets can be found on Zenodo:
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15258101.svg)](https://doi.org/10.5281/zenodo.15258101)

* **Phantom Hip**
  Folder name: hip_phantom
  - meas_MID00086_FID12781_pd_hip_cor_semac16_FOV280_p2.h5
  - noise_meas_MID00086_FID12781_pd_hip_cor_semac16_FOV280_p2.h5
 
* **Phantom Spine**
  Folder name: spine_phantom
  - meas_MID00380_FID13479_pd_spine_cor_semac12_FOV320_p2.h5
  - noise_meas_MID00380_FID13479_pd_spine_cor_semac12_FOV320_p2.h5
 
* **In Vivo Hip**
  Folder name: Invivo_hip
  - meas_MID00228_FID58568_pd_tse_cor_bw401_SEMAC12.h5
  - noise_meas_MID00228_FID58568_pd_tse_cor_bw401_SEMAC12.h5

* **In Vivo Spine 1**
  Folder name: vol0958_Spine
  - meas_MID00580_FID21999_t2_tse_tra_SEMAC6_bw401_os50_pr75_etl16_TR3900_p2.h5
  - noise_meas_MID00580_FID21999_t2_tse_tra_SEMAC6_bw401_os50_pr75_etl16_TR3900_p2.h5
 
* **In Vivo Spine 2**
  Folder name: vol1095_Spine
  - meas_MID00857_FID09954_t2_semac_ax_bw401_os50_RL.h5
  - noise_meas_MID00857_FID09954_t2_semac_ax_bw401_os50_RL.h5
 
* **In Vivo Spine 3**
  Folder name: vol1106_Spine
  - meas_MID00777_FID11019_t2_semac8_ax_bw401_p2_os50_RL.h5
  - noise_meas_MID00777_FID11019_t2_semac8_ax_bw401_p2_os50_RL.h5
 

Once datasets are downloaded, add the folders in the folder "MR_data".

To obtain the figures in the paper, open the file "main_file.m". Choose the dataset in the section "Choose Dataset" in the code and then simply run the code to obtain the figures for the chosen dataset. The figures and their corresponding datasets are noted below.

 

## Figure 2 and S3 (Evaluation in a Hip-Implant Phantom)

In "main_file.m" and in "Choose Dataset" section in the file, comment all datasets except "hip_phantom".

Uncomment the dataset "hip_phantom" in "Choose Dataset" section.

Run "main_file.m".


## Figure 3 and S2 (Evaluation in a Spine-Implant Phantom)

In "main_file.m" and in "Choose Dataset" section in the file, comment all datasets except "spine_phantom".

Uncomment the dataset "spine_phantom" in "Choose Dataset" section.

Run "main_file.m".


## Figure 4 and S4 (In vivo evaluation in a patient with Total Hip Replacement)

In "main_file.m" and in "Choose Dataset" section in the file, comment all datasets except "Invivo_hip".

Uncomment the dataset "Invivo_hip" in "Choose Dataset" section.

Run "main_file.m".


## Figure 5 and S5 (In vivo evaluation in a patient with Transforaminal Lumbar Interbody Fusion)

In "main_file.m" and in "Choose Dataset" section in the file, comment all datasets except "vol0958_Spine".

Uncomment the dataset "vol0958_Spine" in "Choose Dataset" section.

Run "main_file.m".


## Figure S6 and S7 (In vivo evaluation in a patient with anterior lumbar interbody fusion)

In "main_file.m" and in "Choose Dataset" section in the file, comment all datasets except "vol1095_Spine".

Uncomment the dataset "vol1095_Spine" in "Choose Dataset" section.

Run "main_file.m".


## Figure S8 and S9 (In vivo evaluation in a patient with transforaminal lumbar interbody fusion)

In "main_file.m" and in "Choose Dataset" section in the file, comment all datasets except "vol1106_Spine".

Uncomment the dataset "vol1106_Spine" in "Choose Dataset" section.

Run "main_file.m".

