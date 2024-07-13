# AEM-v2


## **Automated Electromagnetic MKID Simulations**

This repository is the updated version of AEM. 

**AEM** is an app developed for the automation of design and simulation of MKID pixels for MKID array/prototype building using MATLAB, the EM simulation software: Sonnet and the SonnetLab toolbox. This work was done in collaboration between Maynooth University, Dublin Institute for Advanced Studies and Dublin City University, Ireland. If any of the original scripts in this repository are used in scientific publications, please cite the original author (See citation.cff). 

AEM currently only operates with an MKID pixel with an interdigitated capacitor and a 4 ground plane polygons surrounding the MKID in the configuration below. The user is free to design anything else (I.e. Inductor, feedline, antenna, etc) within the project file as AEM will not interact with them.

  <img src="https://github.com/user-attachments/assets/8a3c5b20-dc2c-4749-8611-4a9fb329d784" alt="xgeom" width="400" height="400">



You can find more information about AEM in the following paper:

doi.org/10.1007/s10909-024-03103-3

### **MKIDs (Microwave Kinetic Inductance Detectors)** 
MKIDs are thin-film superconducting LC resonators that detect photons with energies above hv > 2delta (delta is the superconducting band gap). The advantage of MKIDs over other superconducting detectors is the ease of multiplexing the pixels. In an array, each MKID has a unique resonant frequency that is controlled by the pixels geometrical design. In the most common case, the inductive portion of the MKID remains the same across pixels while the interdigitated capacitor is varied.

Before fabrication, it is important to design and simulate each pixel so that the fabricated MKID’s behaviour is more predictable. However, for densely packed arrays, it becomes impractical to simulate the characteristics of every pixel by hand. Current methods of designing MKID arrays chose higher-order interpolation techniques, wherein a couple of MKIDs (E.g. 1 pixel in every 50) are simulated correctly by hand and the designs in between are interpolated.

This method can be seen however to contribute to reducing the pixel yield across the array as resonant frequency of these pixels is highly non-linear. This contribution to lowering pixel yield becomes much more prevalent for MKIDs that are closely spaced in frequency space. For MKIDs, the current ideal spacing is 2MHz apart.
AEM is an app developed for the automated simulation of every pixel in an array to match specific resonant frequencies chosen by the user as close as physically possible. It also solves for the coupling quality factor of each pixel to be within a set range. AEM is predicted to increase the survivability of pixels in densely packed arrays and significantly reduce the time required to design arrays.

The scripts provided make use of the EM software Sonnet and the MATLAB toolbox SonnetLab. Sonnet is the most common EM software used to design MKIDs as it accurately simulates the behaviour of the pixel. The MKID structure in Sonnet is a 2D representation which is used with Method of Moment statistics to model the behaviour.  As MKIDs are thin film structures, this 2D model is acceptable.

AEM is also fairly modular and divides its method for solving for resonant frequency and Qc factor in individual scripts. If the user has a resonant structure that is not compatible with this version of AEM, please feel free to use the scripts provided with AEM to design your own automation techniques and cite the author.

**Important To Note:** 
The SonnetLab Toolbox scripts included here are slightly edited in order to work with the author’s settings and the latest versions of Sonnet. The edits made are as follows:

In *v8.0* > *SonnetPath.m* > *Line 189* > added: 

      aSonnetPath=strrep(aSonnetPath,'oe','onne');

This correction was needed as the path for Sonnet would return Soet Software\version number. This correction gives the correct path: \Sonnet Software\version number.

In *v8.0* > *SonnetProject.m* > *Line 953* > added: 

      elseif floor(aVersion) == 18

         fprintf(aFid, 'FTYP SONPROJ 18 ! Sonnet Project File\n');
      
and in *Line 969* > added:

      elseif floor(aVersion) == 18

         fprintf(aFid, 'FTYP SONNETPRJ 18 ! Sonnet Project File\n');

These corrections were added so that the SonnetLab Toolbox could would with the latest version of Sonnet to date (Version 18).
      
                    
### **Important Steps Before Using AEM**
The AEM application is easy to use, however certain steps should be taken into consideration before using the code.


**Single Pixel Design Before Automation**

AEM will require an initial “Starting Geometry” to begin automation (Please See “How to Use AEM”). While AEM will (in most cases) perform the automation to completion, it is advisable to construct and simulate a single MKID by hand that has a quality factor and resonant frequency that is within the general bounds intended by the user. This significantly reduces the runtime of the automation as it reduces the number of required variations to perform by AEM.

For Example, if the user wants to automate 2,000 MKIDs between 4-8GHz with Qc between 20,000 & 30,000, it is advisable to construct and simulate a single MKID by hand with f0 ~4.2GHz, Qc ~ 30,000.

This will give the user a general idea for the starting dimensions of the pixel (Capacitor Finger Spacing, Capacitor Finger thickness, Surrounding GND Plane dimensions, Coupling Bar Thickness & Length) and allows AEM to reduce the total number of parameters to vary during the automation.

In some cases, if this step is not performed beforehand, the automation may be unsuccessful due to the geometry being unable to reach the given Qc range set by the user after all possible variations have been performed. 

### **Important Steps Before Using AEM**
Before using AEM, it is necessary to follow the steps below:

1. In MATLAB, set your current path to the same folder that contains the Sonnet project files.
2. Also, set your current folder to the same folder as the Sonnet project files.
3. Make sure to include the AEM Lk scripts, SonnetLab Toolbox scripts and intersection scripts in your current path.
4. In the Sonnet Job Queue window, set the job queue to Auto Run.
5. In each Sonnet geometry file, make sure the output of the data file(i.e. csv file) is in the project folder (same folder as the geometry file).
6. During the automation, do not change the current folder. This will throw errors in the automation as AEM Lk will be unable to find the project/log files.

### **Recommended Sonnet Settings**
Since individual MKID pixels typically include a single dip in the S21 parameter dictated by the resonant frequency and quality factor of the pixel, it is recommended to extract these values as accurate as possible within the simulation software (Sonnet). 
As such, the following are recommended settings used in Sonnet for MKID simulations:
In *EM Options* > *Advanced Options*
**Check;** *De-Embbed*, *Enhanced Resonance Detection*, *Q-Factor Accuracy*

## **How To Use AEM**
AEM is currently only optimized for an MKID with an interdigitated capacitor and a GND plane surrounding the entire pixel. Future updates will include other variations of this arrangement.


1)	Open the AEM application.

    <img src="https://github.com/user-attachments/assets/b824d5a3-3860-405c-811e-0c7098826bb5" alt="AEM GUI" width="500" length="500"/>


2)	Import the “Starting Geometry” Project File into AEM. The “Starting Geometry” will consist of an interdigitated capacitor area and four polygons surrounding the MKID pixel. A general design layout is shown here and also provided in the zip file as a guide. All other design choices (i.e. inductor design, size of pixel, feedline design) are free to choose. **Please Note:** For the automation to work correctly, the left and the right interdigitated capacitor polygons must be the same length (Y-Axis).
    <img src="https://github.com/user-attachments/assets/65a99e55-8638-40a9-a1fe-0d3b375a0f6b" alt="Starting Geometry AEM" width="500">



3)	Choose the Start, End & number of resonators. This will create a list of equidistant resonant frequencies from Start to End.
4)	If you require resonators that are not equidistant in frequency space, select the Non-Equidistant Resonators option. This option will ask you to import a txt file containing all your desired resonances (MHz) in the following form: SHOW PIC OF NON EQUIDISTANT TXT FILE.
5)	 Choose your Mesh Level. The Mesh Level defines how accurate the simulation is but also how fast the automation is as well. For more details on Mesh, please see the Sonnet User’s manual: https://www.sonnetsoftware.com/support/downloads/manuals/st_users.pdf
6)	The coordinates in the top right of the application (X1, X2, Y1, Y2) dictate the coordinates of the box in the GND plane which the MKID pixel sits in. If you suspect these coordinates are not correct for your geometry, you can select the coordinates in the visual representation of the MKID in AEM to display coordinates and adjust any errors.
7)	Select the Capacitor Spacing. This is the distance (Y-Direction) between interdigitated capacitor fingers.
8)	Select the Finger Thickness. This is the width (Y-Direction) of each interdigitated capacitor finger.
9)	Select the initial Coupling Bar Thickness. This again is the width (Y-Direction) of the coupling bar. This value will most likely change during parameterization in order to control quality factor (Qc) however, to reduce the number of iterations required, please see Single Pixel Design Before Automation.
10)	Start Automation.

It is likely that AEM will pause for a few seconds between simulations despite Sonnet finishing a simulation. This pause is usually no longer than 60 seconds and it uncommon. AEM Lk has procedures in place to overcome this error and the automation will continue after a short period.

### **Correcting Data**
AEM contains two main analysis scripts (*Auto_Sim* and *Auto_Extract*) that facilitate simulation, data analysis and error catching. Sonnet’s output files (.csv files) can contain some non-physical values that must be identified during automation. These errors include; |S21| above 1, the S21 parameter “falling off” after resonance, no resonance found in the frequency sweep etc. 
This errors are typically caught by AEM and are corrected by either varying the frequency sweep range or removing data points. In the case of removing data points, this only occurs in the  |S21|>1 case and has shown no effect on resonant frequency or quality factor of the simulation. 

The .zip found in this repository contain scripts from the following:

**SonnetLab Toolbox:** https://www.sonnetsoftware.com/support/sonnet-suites/sonnetlab.html

**Intersections:** Douglas Schwarz (2024). Fast and Robust Curve Intersections (https://www.mathworks.com/matlabcentral/fileexchange/11837-fast-and-robust-curve-intersections), MATLAB Central File Exchange. Retrieved July 10, 2024.
