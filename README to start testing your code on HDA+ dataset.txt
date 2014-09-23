#####################
=== Introduction: ===
#####################

Our main script is named "fullPipeLineScript.m" and is located in hda_code\detection_reid_pipeline\
In "fullPipeLineScript.m" set the "hdaRootDirectory" variable to the path where you downloade the HDA dataset to, and add to the MATlab's path the "hda_code" folder.
i.e.,:  hdaRootDirectory ='/home/dario/Desktop/WorkNoSync/HDA_Dataset';
		addpath(genpath('/home/dario/Desktop/Dropbox/Work/hda_code'));

Run the "fullPipeLineScript.m" without any further changes to see a running example.

This example uses the provided detections by the ACF pedestrian detector (as described in our paper). It applies the Nearest Neighbour classifier, with Bhattacharrya distance, on HSV color histograms extracted from the body parts and then concatenated.
Among others, it creates the following folders inside the the "HDA_Dataset" folder:

TODO: CORRIGIR NOME DE PASTAS

	hda_experiment_data
	hda_experiment_data\AcfInriaBhattacharryaNNReIdentifierDIRECT
	hda_experiment_data\AcfInriaBhattacharryaNNReIdentifierDIRECT\camera60
	hda_experiment_data\AcfInriaBhattacharryaNNReIdentifierDIRECT\camera60\FilteredCrops

Inside the FilteredCrops folder, it creates the "allF.txt" file that is the INPUT to the re-identification classifier. The designed input format is:
 - One line per detection with the following format: [camera#, frame#, x0, y0, width, height, active] 
  -- camera number, the id of the camera where this detection happened, may be one of the following [02 17 18 19 40 50 53 54 56 57 58 59 60]
  -- frame number, the frame in the video when this detection happened, starts with 1.
  -- the four numbers defining a bounding-box, (origin in the top-left corner of the image)
  -- and the active bit, that is set to 0 if this detection was rejected by the occlusion filter or some other reason.
 
The re-identification classifier (BhattacharryaNNReIdentifier.m) called by the main script (fullPipeLineScript.m) creates the following folder:
	hda_experiment_data\AcfInriaBhattacharryaNNReIdentifierDIRECT\camera60\BhattacharryaNNReIdentifier

And inside it creates the allR.txt file, which is the designed OUTPUT file and the designed input to the evaluation code that will generate a CMC and a Precision/Recall curve. The designed output format is:
 - One line per corresponding detection with the following format: [camera#, frame#, x0, y0, width, height, estimatedIdRank1, estimatedIdRank2, ... ](line is left empty if the "active bit" was set to zero)	
  -- [camera#, frame#, x0, y0, width, height] is the same format as the input
  -- [estimatedIdRank1, estimatedIdRank2, ...] is the ranked list of estimated IDs for the corresponding detection

TODO: RE-DO THIS EXAMPLE WITH DIRECT EXPERIMENT  
If you examine the generated allF.txt and allR.txt you will find in the first two lines:
	allF:
60,14,1925.2,258.89,116.49,212.13,1
60,30,968.97,491.33,381.97,965.87,1
60,31,1364.5,441.68,297.99,904.94,1
	allR:
60,14,1925.2,258.89,116.49,212.13,42,10,19,75,32,14,16,66,58,73,64,33,62,46,72,12,67,22,20,21,25,15,38,5,61,31,71,43,48,34,65,68,37,49,60,17,8,53,56,24,76,69,59,44,40,23,70,1,41,50,74,52,63,35,47,13,45,77,26,28
60,30,968.97,491.33,381.97,965.87,15,42,33,63,35,20,8,46,71,24,72,69,58,64,44,14,74,25,13,43,50,31,52,17,22,32,1,5,23,12,60,26,68,61,73,56,76,75,38,19,10,62,59,21,34,53,40,70,66,65,77,49,41,37,16,67,47,28,45,48
60,31,1364.5,441.68,297.99,904.94,15,14,52,69,46,35,33,8,24,50,23,44,20,13,63,26,74,71,42,25,58,72,60,32,64,17,12,5,31,22,65,56,43,76,41,1,73,40,59,37,49,66,53,47,61,68,70,16,62,38,19,21,10,75,48,77,28,67,45,34
	
 
#########################################
=== To test your classification code: ===
#########################################

1) ADD YOUR CODE TO "hda_code" folder
Our main script is in hda_code\detection_reid_pipeline\

2) SET global variables to desired values. 
You may set the following global variables in the sub script "setUserDefinedExperimentParameters.m",
or in the main script "fullPipeLineScript.m" below where that subscript is called (line 54), 
or simply use the default values (which were used in the example above).
For a full description of each global variable see the comments in "declareGlobalVariables.m".

The most important are:

SET "experimentVersion" variable to an unique number or name that describes what experiment you will run. In "setUserDefinedExperimentParameters.m" "experimentVersion" is checked to determine the rest of the global variables values.
i.e.,		 : experimentVersion = '_myTest001';
default value: experimentVersion = 'DIRECT';

SET "reIdentifierHandle" variable to your re-identification classifier function matlab name
i.e.		 : reIdentifierHandle = @yourClassifierName;
default value: reIdentifierHandle = @BhattacharryaNNReIdentifier;



TODO: POINT TO PART OF CODE THAT TURNS TXT INPUT INTO PIXELS
