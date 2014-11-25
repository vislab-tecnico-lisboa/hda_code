%% setUserDefinedExperimentParameters error checking

reIdentifierName =  func2str(reIdentifierHandle);
featureExtractionName = func2str(featureExtractionHandle);
% if feature extraction function is called extractXXX, remove the extract
% looks better this way when using it in folders and other naming situations
if strncmp(featureExtractionName,'extract',7)
    featureExtractionName = featureExtractionName(8:end);
end

% There are no False Positives if the "detector" is the manual annotations,
% so if set to 1, resetting it to 0
if strcmp(detectorName, 'GtAnnotationsClean') || strcmp(detectorName, 'GtAnnotationsAll')
    if useFalsePositiveClass
        warning(['setUserDefinedExperimentParameters: There are no False Positives in the ' detectorName ' annotations. Setting useFalsePositiveClass to 0.'])
        useFalsePositiveClass = 0;
    end
end

% Check if train and test set are non-overlapping
if ~isempty(intersect(trainCameras,testCameras))
    warning(['Training set and testing set cameras overlap, are you sure you want to do this?' ...
        ' (cameras ' int2str(intersect(trainCameras,testCameras)) ')'])
end

% If either the classifier or the feature extraction is MSCR, the other
% must be MSCR as well.
if strcmp(reIdentifierName,'MSCR_NN_ReId') && ~strcmp(featureExtractionName,'extractMSCR')
    warning(['reIdentifier set to MSCR_NN_ReId and featureExtraction set to ' featureExtractionName '. MSCR_NN_ReId only works with extractMSCR as featureExtraction.'])
    warning(['Setting featureExtraction to extractMSCR'])
    featureExtractionHandle = @extractMSCR;
    featureExtractionName = func2str(featureExtractionHandle);
end
if ~strcmp(reIdentifierName,'MSCR_NN_ReId') && strcmp(featureExtractionName,'extractMSCR')
    warning(['reIdentifier set to ' reIdentifierName ' and featureExtraction set to ' featureExtractionName '. extractMSCR requires MSCR_NN_ReId as RE-ID classifier.'])
    warning(['Setting reIdentifier to MSCR_NN_ReId'])
    reIdentifierHandle = @MSCR_NN_ReId;
    reIdentifierName =  func2str(reIdentifierHandle);
end