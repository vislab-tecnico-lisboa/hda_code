Code of the HDA+ dataset
===

This is evaluation software to produce perfectly comparable CMC curves and Precision/Recall values with **your re-identification algorithm** on the HDA+ dataset described here: http://vislab.isr.ist.utl.pt/hda-dataset/

To download this dataset, contact (alex at isr ist utl pt)

### Getting Started

* To visualize the dataset with overlaying manual annotations run MATlab script HDA_Dataset\hda_code\visualization\ RunToVisualize.m and do the following steps:

 1. On the window that shall appear named "VBB Labeler" click on the menu "Video -> Open"
 2. Select a *.SEQ file from the folder “hda_image_sequences_matlab”
 3. On the "VBB Labeler" window click on the menu "Annotation -> Open"
 4. Select the appropriate *.TXT file from the folder “hda_annotations"
 5. On the "VBB Labeler" window click the Play button in the lower-left part of the window.

* To see a running example of a sample re-identification algorithm plus the evaluation code,

 1. open HDA_Dataset\hda_code\detection_reid_pipeline\ Computer_Specific_Dataset_Directory.m,
 2. set the hdaRootDirectory variable,
 3. add to the Matlab path the hda_code folder (fill in the addpath(genpath( ... )) ),,
 4. and then run the MATlab script HDA_Dataset\hda_code\detection_reid_pipeline\ fullPipeLineScript.m (more information in hda_code/GettingStarted.txt)

**If you use this dataset, please cite:**

["The HDA+ data set for research on fully automated re-identification systems." D. Figueira, M. Taiana, A. Nambiar, J. Nascimento and A. Bernardino, VS-RE-ID Workshop at ECCV 2014.](http://vislab.isr.ist.utl.pt/wp-content/uploads/2012/12/hdaplus_eccvws.pdf)

~~~ Prerequisites: This dataset requires Matlab (TM).
