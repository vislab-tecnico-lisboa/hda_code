function BhattacharryaNNReIdentifier()
%Reads filtered detections and generated ReId output randomly selecting the people Id for the ranks
    
	declareGlobalVariables,

    trainingDataStructure = createTrainStructure();    
    trainSpidVector = [trainingDataStructure.personId];
    unique_trainSpid = unique([trainingDataStructure.personId]);
    nPed = length(unique_trainSpid);
        
    for testCamera = testCameras
        fprintf('BhattacharryaNNReIdentifier: Working on camera: %d\n',testCamera);
   
        % No need to filter by test camera here, since we're using
        % trainCameras list to create the structure, and it selects which
        % cameras to use there
        % Filter out test camera from training data structure
        % trainDataStructNoTestCamera = trainingDataStructure([trainingDataStructure.camera] ~= testCamera);
        % numberTrainingPedestrians = length(unique([trainDataStructNoTestCamera.personId]));
        
        %Work on one file at a time
        filteredCropsDirectory = [experimentDataDirectory sprintf('/camera%02d',testCamera) '/FilteredCrops'];
        reIdsDirectory         = [experimentDataDirectory sprintf('/camera%02d',testCamera) '/ReIds' reIdentifierName];
        featuresDirectory      = [thisDetectorDetectionsDirectory sprintf('/camera%02d',testCamera) '/Detections'];
        if(~exist(reIdsDirectory,'dir')), mkdir(reIdsDirectory); end;
        if(recomputeAllCachedInformation)
            delete([reIdsDirectory '/info.txt']);
            delete([reIdsDirectory '/allR.txt']);
        end
        if exist([reIdsDirectory '/allR.txt'],'file')
            cprintf('blue',['allR.txt already exists at ' reIdsDirectory '\n']),
            continue,
        end
        fid = fopen([reIdsDirectory '/info.txt'],'w');
        fprintf(fid,'List of estimated ID''s for each crop, sorted accoring to rank.\n');
        fprintf(fid,'Detections that were filtered out, and thus have their "active" bit to zero, are not processed and an empty line is left\n');
        fprintf(fid,'Format: \n');
        fprintf(fid,'camera#, frame#, x0, y0, width, height, estimatedId1, estimatedId2, ...\n');
        fclose(fid);

        filteredCropsMat = dlmread([filteredCropsDirectory '/allF.txt']);
        testFeatures = load([featuresDirectory '/featHSV(4 Parts)[10,10,10]eq.mat']);
        nFiles=size(filteredCropsMat,1);
        wbr = waitbar(0, ['Bhattacharrya NN ReIdentifying on camera ' int2str(testCamera) ', image 0/' int2str(nFiles)]);
        allRMatToSave = zeros(nFiles,6+nPed);
        for count=1:nFiles
            waitbar(count/nFiles, wbr, ['Bhattacharrya NN ReIdentifying on camera ' int2str(testCamera) ', image ' int2str(count) '/' int2str(nFiles)]);
            dataLine = filteredCropsMat(count,:);
            if dataLine(7) == 0    % if "active" bit turned off
                continue,          % leave line in matrix empty
            end
            
            % TODO: INCLUDE HERE IMAGE CROPPING ON THE FLY, AND FEATURE
            % EXTRACTION
            
            dist1toAll = BhattDist1toAll(testFeatures.F(count,:), [trainingDataStructure.F]');
            
            % Compute minimum of distances for each train ped (not sample)
            dist1toPeds = zeros(1,nPed);
            dist1toPedsPIDs = zeros(1,nPed);
            for trainPed = 1:nPed
                % indTped = trainSpidVector == dsetTrain(trainPed).pid;
                indTped = trainSpidVector == unique_trainSpid(trainPed);
                if ~isempty(min(dist1toAll(indTped)))
                    dist1toPeds(trainPed) = min(dist1toAll(indTped));
                else
                    % Since the purging, there is no instances of this ped
                    dist1toPeds(trainPed) = Inf;
                end
                
                % dist1toPedsPIDs(trainPed) = dsetTrain(trainPed).pid;
                dist1toPedsPIDs(trainPed) = unique_trainSpid(trainPed);
            end
            
            % Sort the distances to all peds, and find index of ground truth
            [Y, I] = sort(dist1toPeds);
            dist1toPedsPIDsI = dist1toPedsPIDs(I);
                      
            allRMatToSave(count,:) = [dataLine(1:6) dist1toPedsPIDsI];
        end
        close(wbr);
        
        dlmwrite([reIdsDirectory '/allR.txt'],allRMatToSave);
        cprintf('*red',['Saved allR.txt to ' reIdsDirectory '\n'])        
    end
    
return
