###################################################################
#                                                                 #
#    Caltech Pedestrian Dataset Code                              #
#    www.vision.caltech.edu/Image_Datasets/CaltechPedestrians/    #
#    Piotr Dollar (pdollar-at-caltech.edu)                        #
#                                                                 #
###################################################################

1. Introduction.

If using the Caltech Pedestrian Dataset, please cite the following works in any resulting publication:

 @inproceedings{sdollarPAMI11peds,
   author = "P. Doll\'ar and C. Wojek and B. Schiele and P. Perona",
   title = "Pedestrian Detection: An Evaluation of the State of the Art",
   journal ={PAMI},
   volume = {99},
   number = {PrePrints},
   issn = {0162-8828},
   year = {2011},
   doi = {http://doi.ieeecomputersociety.org/10.1109/TPAMI.2011.155}
 }

 @inproceedings{CVPR09peds,
   author = "P. Doll\'ar and C. Wojek and B. Schiele and P. Perona",
   title = "Pedestrian Detection: A Benchmark",
   booktitle = "CVPR",
   year = "2009",
 }

###################################################################

2. License.

This code is published under the LGPL license.
Please read lgpl.txt and gpl.txt for more info.

###################################################################

3. Installation.

This code is written for the Matlab interpreter (tested with versions 2007b-2010a) and requires the Matlab Image Processing Toolbox. Additionally, Piotr's Matlab Toolbox (version 2.61 or later) is also required. It can be downloaded at:
  http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html

Note that any pedestrian data must be downloaded separately from the code. All the provided routines expect the data, annotations and res files to be in a fixed location. By default, the seq files should be in $code/$name/videos/ and the annotations in $code/$name/annotations/, where $code is the directory containing the code and $name is the name of the database (e.g. data-USA, data-INRIA, etc.). For example, the first video in the first set might be $code/$name/videos/set00/V000.seq and the corresponding annotation $code/$name/annotations/set00/V000.vbb. To set the currently active database or to change the default data location, see dbInfo.m. Generated results for the purpose of evaluation should be placed in $code/$name/res/$alg where $alg is an algorithm specific directory. See the provided result files for examples.

###################################################################

4. Getting Started.

Place downloaded data and annotations in appropriate subdirectories, e.g., data-USA/videos and data-USA/annotations (see above). Alter dbInfo.m to point to the appropriate data location. Then run "vbbPlayer" from the Matlab prompt to display a random seq file with an overlaid annotation (note that you cannot use the file menu in the GUI to load a new video). For more information about retrieving/manipluating annotations, see vbb.m.  For more information about dealing with seq files, see seqIo.m (part of Piotr's Matlab Toolbox). To generate the ROC plots for the appropriate database, see dbEval.m. You can generate the INRIA full image curves by running dbEval.m with the default settings (assuming you first download the data/annotations/res and set dbInfo.m appropriately).

###################################################################

5. Contents.

Code:
   dbBrowser  - Browse database annotations and detection results.
   dbEval     - Evaluate and plot all detection results (alter internal flags as needed).
   dbInfo     - Specifies data amount and location (alter internal flag as desired).
   vbb        - Data structure for video bounding box (vbb) annotations.
   vbbLabeler - Video bound box (vbb) Labeler.
   vbbPlayer  - Simple GUI to play annotated videos (seq files)

Other:
    lgpl.txt            - Lesser GPL license information.
    gpl.txt             - GPL license information.
    readme.txt          - This file.
    vbbIcons.mat        - Icons used in vbbLabeler.

###################################################################

6. History / ToDo.

Version 3.0.0 (09/04/2011)
 - major update of experiments to correspond to PAMI 2011 paper
 - dbEval.m: major overhaul (see PAMI paper for new experiment setup)
 - dbInfo.m: refactored to make more powerful and easier to use
 - dbBrowser.m: minor changes (using new dbInfo.m)

Version 2.2.0 (08/01/2010)
 - vbbLabeler: minor fixes
 - added algorithms/databases to evaluation code
 - various tweaks/improvements of code

Version 2.1.0 (04/18/2010)
 - vbbLabeler: major overhaul
 - associate unique color with each algorithm
 - added code for evaluating ETH and TUD-Brussels datasets

Version 2.0.0 (03/15/2010)
 - uses bbGt('evalRes') in place of evalFrame.m
 - vbb.m: ability to export/import from single frame annotations (.txt files)
 - bbDetect.m: fixed bugs in plotBbSheet
 - vbbLabeler.m: label bw videos
 - dbEval.m: new evalution criterion (see website)
 - minor tweaks throughout

Version 1.0.0 (05/15/2009)
 - initial version

###################################################################
