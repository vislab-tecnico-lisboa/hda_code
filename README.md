Code of the HDA+ dataset
===

This is evaluation software to produce perfectly comparable CMC curves and Precision/Recall values with **your re-identification algorithm**, or produce perfectly comparable MD/FPPI curves for **your pedestrian detection algorithm** on the HDA+ dataset described here: http://vislab.isr.ist.utl.pt/hda-dataset/

To download this dataset, contact (alex at isr ist utl pt)

### Getting Started

* To visualize the dataset with overlaying manual annotations  do the following steps:

 1. **Open** `HDA_Dataset\hda_code\detection_reid_pipeline\ Computer_Specific_Dataset_Directory.m`,
 2. Set the `hdaRootDirectory` variable to the path where you put the `HDA_Dataset`,
 3. Add to the Matlab path the `hda_code` folder (fill in the `addpath(genpath( ... ))` ),,
 4. and then run MATlab script `HDA_Dataset\hda_code\visualization\ RunToVisualize.m`

* To see a running example of a sample re-identification algorithm plus the evaluation code, do the following:

 1. **Open** `HDA_Dataset\hda_code\detection_reid_pipeline\ Computer_Specific_Dataset_Directory.m`,
 2. Set the `hdaRootDirectory` variable to the path where you put the `HDA_Dataset`,
 3. Add to the Matlab path the `hda_code` folder (fill in the `addpath(genpath( ... ))` ),,
 4. and then run the MATlab script `HDA_Dataset\hda_code\detection_reid_pipeline\ fullPipeLineScript.m` 
(more information in [hda_code/GettingStarted.txt](https://github.com/vislab-tecnico-lisboa/hda_code/blob/master/GettingStarted.txt))

**If you use this dataset, please cite:**

["The HDA+ data set for research on fully automated re-identification systems." D. Figueira, M. Taiana, A. Nambiar, J. Nascimento and A. Bernardino, VS-RE-ID Workshop at ECCV 2014.](http://vislab.isr.ist.utl.pt/wp-content/uploads/2012/12/hdaplus_eccvws.pdf)

~~~~~~~~~~~~~~~~
~ Prerequisites: This dataset requires Matlab (TM).
~~~~~~~~~~~~~~~~
