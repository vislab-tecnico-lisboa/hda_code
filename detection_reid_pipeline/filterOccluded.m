function filterOccluded()
%filterOccluded
%   Reads the information on the cropped images and adds a flag
%   indicating whether the crop should be used for testing a RE-ID system.
%   The filtering is currently based on the inter-occlusion ratio of each crop.
%
%   When "recomputeAllCachedInformation" is set, the output directory is
%   cleared before computing the new results.
%   When "recomputeAllCachedInformation" is false, the function still
%   performs all the computations, but only creates the output files
%   which are missing. (skipping some computations would not save time).

declareGlobalVariables,

%Default parameters
% if(~exist('minimumScore','var')),    minimumScore  = 0; end;
% if(~exist('minimumHeight','var')),   minimumHeight = 68; end;
%     if ~exist('useMutualOverlapFilter','var')
%         useMutualOverlapFilter = 1;
%     end

for testCamera = testCameras
    %if ~useMutualOverlapFilter
    %    displayString = ['Setting active flag to 1 on camera ' int2str(testCamera)];
    %else
        displayString = ['Filtering on camera ' int2str(testCamera) ];
    %end
    display([displayString ' ']),
    
    cropsDirectory = sprintf('%s/camera%02d/Crops',experimentDataDirectory,testCamera);
    filteredCropsDirectory = sprintf('%s/camera%02d/FilteredCrops',experimentDataDirectory,testCamera);
    if(~exist(filteredCropsDirectory,'dir')), mkdir(filteredCropsDirectory); end;
    if(recomputeAllCachedInformation)
        warning('off','MATLAB:DELETE:FileNotFound')
        delete([filteredCropsDirectory '/info.txt']);
        %This function does not delete the cropped images, as those are responsibility of the "crop.m" function
        delete([filteredCropsDirectory '/allF.txt']);
        warning('on','MATLAB:DELETE:FileNotFound')
    end
    if exist([filteredCropsDirectory '/allF.txt'],'file')
        cprintf('blue',['allF.txt already exists at ' filteredCropsDirectory '\n']),
        continue,
    end
    
    % Create file describing the information encoded in the other file
    fid = fopen([filteredCropsDirectory '/info.txt'],'w');
    fprintf(fid,'Crop rectangle information, including the "active" flag.\n');
    fprintf(fid,'Format: \n');
    fprintf(fid,'camera#, frame#, x0, y0, width, height, active\n');
    fclose(fid);

    % To filter out test samples which the corresponding pedestrians
    % are not in the training set
    trainingDataStructure = createTrainStructure(0);
    unique_trainStruct_Pid = unique([trainingDataStructure.personId]);
    allDplusGT = GTandDetMatcher('detections');
    unique_testSamples_personIds = unique(allDplusGT(:,3));
    pIdofTestNotInTrain = setdiff(unique_testSamples_personIds,[unique_trainStruct_Pid 999]);

    cropsMat = dlmread([cropsDirectory '/allC.txt']);
    nFiles=size(cropsMat,1);
    wbr = waitbar(0, [displayString ', image 0/' int2str(nFiles)]);
    dividerWaitbar=10^(floor(log10(nFiles))-1); % Limiting the access to waitbar
    % Work on one file at a time
    MatToSave = zeros(nFiles,7);
    for count=1:nFiles
        if (round(count/dividerWaitbar)==count/dividerWaitbar) % Limiting the access to waitbar
            waitbar(count/nFiles, wbr, [displayString ', image ' int2str(count) '/' int2str(nFiles)]);
        end
        dataLine = cropsMat(count,:);
        confidenceScore = dataLine(7);
        overlap = dataLine(8);
        GeometricallyFullyVisible = dataLine(9);
        % If user does not wish to use overlap filter put all active flags to 1
        active = -1;
        if(~useMutualOverlapFilter)
            active = 1;
        elseif overlap<=maximumOcclusionRate
            % If below overlap threshold, not occluded, put active flag to 1
            active = 1;
        elseif overlap>maximumOcclusionRate && GeometricallyFullyVisible==1
            % If above overlap threshold, but with GFV (fully visible flag) to 1, not occluded, put active flag to 1
            active = 1;
        elseif overlap>maximumOcclusionRate && GeometricallyFullyVisible==0
            % If above overlap threshold, and with GFV to zero, occluded, put active flag to 0
            active = 0;
        else
            error('Not supposed to get here, did we forget a possible case?')
        end
        
        % Not filtering by detection confidence at the moment, but if
        % you want to, you can do it here.
        % Filter by detection confidence
        %if confidenceScore < minimumConfidence
        %    active = 0;
        %end
        
        % Filtering out test samples which the corresponding pedestrians
        % are not in the training set
        pedID = allDplusGT(count,3);
        if max(pedID == pIdofTestNotInTrain)
            active = 0;
        end
                
        MatToSave(count,:) = [dataLine(1:6), active];
        
    end
    close(wbr);
    
    dlmwrite([filteredCropsDirectory '/allF.txt'],MatToSave);
    cprintf('*[1,0,1]',['Saved allF.txt to ' filteredCropsDirectory '\n'])
end
return
