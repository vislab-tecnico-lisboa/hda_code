function writeExpermentParametersTxt()

    declareGlobalVariables,

    fid = fopen([experimentDataDirectory '/experimentParameters.txt'],'w');
    fprintf(fid,['Parameters for experiment v' experimentVersion '.\n']);
    fprintf(fid,['Training Cameras: [' int2str(trainCameras) ']\n']);
    fprintf(fid,['Test Cameras    : [' int2str(testCameras) ']\n']);
    fprintf(fid,['Detector name                               : ' detectorName '\n']);
%     fprintf(fid,['Minimum detection confidence score threshold: ' num2str(minimumScore) '\n']);
%     fprintf(fid,['Minimum detection height in pixels threshold: ' num2str(minimumHeight) '\n']);
    fprintf(fid,['Use/train False Positive class? (YES/NO)    : ' int2str(useFalsePositiveClass) '\n']);
    fprintf(fid,['Filter detections by overlap? (YES/NO)      : ' int2str(useMutualOverlapFilter) '\n']);
    fprintf(fid,['Maximum overlap beween detections threshold : ' num2str(maximumOcclusionRate) '\n']);
    fprintf(fid,['Re-Identifier name                          : ' reIdentifierName '\n']);    
    fprintf(fid,['Feature extraction name                     : ' featureExtractionName '\n']);    
    fprintf(fid,['Using training set                          : ' trainingSetPath '\n']);    

    fclose(fid);

    cprintf('*black',['=============== Parameters for experiment v' experimentVersion ': ================\n']);
    cprintf('black',['Training Cameras: [' int2str(trainCameras) ']\n']);
    cprintf('black',['Test Cameras    : [' int2str(testCameras) ']\n']);
    cprintf('black',['Detector name                               : ' detectorName '\n']);
%     cprintf('black',['Minimum detection confidence score threshold: ' num2str(minimumScore) '\n']);
%     cprintf('black',['Minimum detection height in pixels threshold: ' num2str(minimumHeight) '\n']);
    cprintf('black',['Use/train False Positive class? (YES/NO)    : ' int2str(useFalsePositiveClass) '\n']);
    cprintf('black',['Filter detections by overlap? (YES/NO)      : ' int2str(useMutualOverlapFilter) '\n']);
    cprintf('black',['Maximum overlap beween detections threshold : ' num2str(maximumOcclusionRate) '\n']);
    cprintf('black',['Re-Identifier name                          : ' reIdentifierName '\n']);    
    cprintf('black',['Feature extraction name                     : ' featureExtractionName '\n']);    
    cprintf('black',['Using training set                          : ' trainingSetPath '\n']);    
    cprintf('*black',['================================================================\n']);
