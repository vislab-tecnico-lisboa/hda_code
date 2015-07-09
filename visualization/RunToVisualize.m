%% Run this file to launch the GUI to visualize the videos and annotations

%  1. Open `HDA_Dataset\hda_code\detection_reid_pipeline\ Computer_Specific_Dataset_Directory.m`,
%  2. Set the `hdaRootDirectory` variable to the path where you put the `HDA_Dataset`,
%  3. Add to the Matlab path the `hda_code` folder (fill in the `addpath(genpath( ... ))` ),,
%  4. and then run MATlab script `HDA_Dataset\hda_code\visualization\ RunToVisualize.m`

run ../detection_reid_pipeline/Computer_Specific_Dataset_Directory_development.m

dbBrowser(hdaRootDirectory),

% Code originally from http://vision.ucsd.edu/~pdollar/toolbox/piotr_toolbox_V2.62.zip (Doll�r Toolbox)
% and http://www.vision.caltech.edu/Image_Datasets/CaltechPedestrians/files/code3.0.0.zip (Doll�r Detection Code)
%
% Improved and partially commented by:
% - F�bio Reis 
% - Dario Figueira 
% - Matteo Taiana





