function [ActiveTestSamples, ActiveTrainSamples, ActivePeds] = filterOccluded()
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
% if a global flag variable is empty, it's treated has false by the if's

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
    % letting it run every time to see how many samples were filtered out
%     if exist([filteredCropsDirectory '/allF.txt'],'file')
%         cprintf('blue',['allF.txt already exists at ' filteredCropsDirectory '\n']),
%         continue,
%     end
    
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

    %% Format of cropsMat: 
    % camera#, frame#, x0, y0, width, height, score, overlapFraction, GFV
    cropsMat = dlmread([cropsDirectory '/allC.txt']);
    nFiles=size(cropsMat,1);
    if waitbarverbose
        wbr = waitbar(0, [displayString ', image 0/' int2str(nFiles)]);
        dividerWaitbar=10^(floor(log10(nFiles))-1); % Limiting the access to waitbar
    end
    % Work on one file at a time
    MatToSave = zeros(nFiles,7);
    if filterOutRepeatedTestSamples,
        % Used when filtering repeated samples, to make sure we don't delete
        % detections of different people just because they happened to coincide
        % in size and position
        allDandGT = GTandDetMatcher('detections'); 
        uniqueSamples = [0 0 0 0 0 0];
        % allDandGT(2,3) = 34; % for DEBUG purposes
    end
    occludedSamplesFiltered = 0;
    testSamplesNotInTrainingSetFiltered = 0;
    repeatedTestSamplesFiltered = 0;
    for count=1:nFiles
        if waitbarverbose
            if (round(count/dividerWaitbar)==count/dividerWaitbar) % Limiting the access to waitbar
                waitbar(count/nFiles, wbr, [displayString ', image ' int2str(count) '/' int2str(nFiles)]);
            end
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
            occludedSamplesFiltered = occludedSamplesFiltered+1;
            
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
            testSamplesNotInTrainingSetFiltered = testSamplesNotInTrainingSetFiltered+1;
        end
        
        % Filtering out repeated test samples (test bounding boxes of exact
        % same size and position)
        % if BB already exists in uniqueSamples disable the active bit, else add it
        if filterOutRepeatedTestSamples,
            BB = [dataLine(2:6) allDandGT(count,3)];

            % DEBUG, trying to see if there are samples of different
            % pedestrians that would be filtered out because of same size and
            % position
            ind = find(sum(uniqueSamples(:,2:5) == repmat(BB(2:5),size(uniqueSamples(:,2:5),1),1),2) == 4);
            if ~isempty(ind) && uniqueSamples(ind,6) ~= allDandGT(count,3)
                warning('samples that seems to be same size and position, but not same ped:')
                warning(int2str(BB)),                     
                warning(int2str(uniqueSamples(ind,:)));
            end

            if find(sum(uniqueSamples(:,2:end) == repmat(BB(2:end),size(uniqueSamples(:,2:end),1),1),2) == 5)
                active = 0;
                repeatedTestSamplesFiltered = repeatedTestSamplesFiltered+1;
            else
                uniqueSamples = [uniqueSamples; BB];
            end
        end        
                
        MatToSave(count,:) = [dataLine(1:6), active];
        
    end
    if waitbarverbose
        close(wbr);
    end
    
    display([int2str(occludedSamplesFiltered) ' occluded samples were filtered out.'])
    display([int2str(testSamplesNotInTrainingSetFiltered) ' test samples that were not in the training set were filtered out.'])
    if filterOutRepeatedTestSamples,
        display([int2str(repeatedTestSamplesFiltered) ' repeated test samples were filtered out.'])
    end
    ActiveTestSamples = sum(MatToSave(:,7));
    ActiveTrainSamples = length(trainingDataStructure);
    ActivePeds =   length(unique_trainStruct_Pid);
    display(['Camera ' int2str(testCamera) ': ' int2str(ActiveTestSamples) ' active test samples, ' ... 
        int2str(ActiveTrainSamples) ' train samples of '  int2str(ActivePeds) ' pedestrians'])
    
    %%
    dlmwrite([filteredCropsDirectory '/allF.txt'],MatToSave);
    cprintf('*[1,0,1]',['Saved allF.txt to ' filteredCropsDirectory '\n'])
end
return
