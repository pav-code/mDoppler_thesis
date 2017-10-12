# mDoppler_thesis
Human activity classification using simulated micro-Dopplers and time-frequency analysis in conjunction with machine learning algorithms: a comparative study for automotive use. Code and tools.

# contact info
Pavel Gueorguiev
email: pavel.gueorguiev@gmail.com
linkedin: https://www.linkedin.com/in/pavelgueorguiev

Fredrik Axelsson
email: freaxels@gmail.com

# Matlab code
freehanddraw.m : A file mean to extract micro-Dopplers from an actual radar signal in Matlab. The user can select the orientation of the object's motion in the data and extract the relevant data, which should be subsequently processed. 

# ANN
ANN_main.m runs an ANN with depth of 1 on the input images first training and then testing. Input parameters are image size, network size and learning rate lambda. This network is not appropriate for expanding to more than a depth of 1. 

# Main
The main.m loads .c3d files, generates a simulated radar response and applies the STFT, CWD and SPWVD algorithms to the signal. It then saves the images to folders for later use. For the .c3d data format it requires the following support files/folders:

loadc3d.m         - required to load the .c3d files into the right format
fInterp.m          - interpolates the input signal
tfr_pkg/mfiles     - the folder contains the time-frequency analysis functions. Any function                                   titled tfrfoo depends on this library.
RemoveWhiteSpace.m - removes all whitespace in the input image 


# tfr_pkg
This folder contains the time-frequency resolution function files. Files in this folder have been altered to give images suitable for a report format. A link to the original files can be found in the thesis report. Modifications were made to the code base to suit this project, most additions have 'Pav-add' in the comment beside the respective line of code.

# emd_pkg
main_cemd.m breaks down the input signal into IMF:s according to the EMD algorithm. The file runs in C through Matlab. The file is associated with the /EMD folder and the /utils folder. 

# CNN
data_helper_scripts : Python helper scripts for images augmentation, resizing, horizontal flipping, removing white spaces. Files that begin with 'popu_' are used to generate lists that are used by the CNN to index the data folder (i.e. images in the data folder, are called by name using the generated textfiles [feel free to remove this feature and simply grab from folder directly]).

MNIST_data : Data used in the MNIST data set. It serves for a sanity check of a CNN, classification accuracy of over 98 percent must be achieved for any viable CNN. Note: cnn_main.py doesn't run this as is, filter sizes must be corrected to an appropriate size, see comment in 'cnn_main.py'.

notes : GPU requirements (for GPU acceleration), TF dependencies and a generic easy to read paper on CNN architectures.
cnn_main.py : Main CNN file. All functions implemented within. Adjustable filter sizes and depths (must match dimensions!!) as well as nodes architecture. 

resize_image_win.py resizes an input image on a Windows OS.


