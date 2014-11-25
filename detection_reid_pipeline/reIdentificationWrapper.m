function reIdentificationWrapper()
%Reads filtered detections and generated ReId output 
% TODO: MORE COMMENTS
    
	declareGlobalVariables,

    trainingDataStructure = createTrainStructure();    
    trainSpidVector = [trainingDataStructure.personId];
    unique_trainSpid = unique([trainingDataStructure.personId]);
    nPed = length(unique_trainSpid);
        
    for testCamera = testCameras
        fprintf('re-identification: Working on camera: %d\n',testCamera);
           
        filteredCropsDirectory = [experimentDataDirectory sprintf('/camera%02d',testCamera) '/FilteredCrops'];

        % Loading allF here (before the if exist test) just to make it easy
        % to re-run MultiView
        filteredCropsMat = dlmread([filteredCropsDirectory '/allF.txt']);
        nFiles=size(filteredCropsMat,1);
        
        reIdsDirectory         = [experimentDataDirectory sprintf('/camera%02d',testCamera) '/ReIds_' reIdentifierName];
        if(~exist(reIdsDirectory,'dir')), mkdir(reIdsDirectory); end;
        if(recomputeAllCachedInformation)
            warning('off','MATLAB:DELETE:FileNotFound')
            delete([reIdsDirectory '/info.txt']);
            delete([reIdsDirectory '/allR.txt']);
            warning('on','MATLAB:DELETE:FileNotFound')
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
        
        % Loading pre-computed body-part masks
        bodypartmaksksDirectory      = [thisDetectorDetectionsDirectory sprintf('/camera%02d',testCamera) '/Detections'];
        masks = load([bodypartmaksksDirectory '/pmskset4_128x64.mat']);
        masks = masks.pmskset;
        if size(masks,1) ~= nFiles
            error(['Number of masks (' int2str(size(masks,1)) ') not equal to number of filtered crops (' int2str(nDetections) '). Maybe they were computed with crowd detections?'])
        end
        
        if strncmp(reIdentifierName,'MultiView',9)
            % Special case: algorithms that take as input the whole test set
            % before outputting the re-identification classifications
            
            testDataStructure = createTestStructure(testCamera);
            filteredTestStruct = testDataStructure(logical(filteredCropsMat(:,7)));

            % if we haved a function
            rankedList = reIdentifierHandle(trainingDataStructure,filteredTestStruct,filteredCropsMat); % OUTPUT: rankedList
            % if we haved a script
            %eval(reIdentifierName)
            
            allRMatToSave = zeros(nFiles,6+nPed);
            allRMatToSave(:,1:6) = filteredCropsMat(:,1:6);
            allRMatToSave(:,7:end) = rankedList'; 
        else
            % Regular case, re-identifier takes one test sample and outputs one
            % classification vector
            wbr = waitbar(0, ['ReIdentifying on camera ' int2str(testCamera) ', image 0/' int2str(nFiles)]);
            allRMatToSave = zeros(nFiles,6+nPed);
            for count=1:nFiles
                waitbar(count/nFiles, wbr, ['ReIdentifying on camera ' int2str(testCamera) ', image ' int2str(count) '/' int2str(nFiles)]);
                dataLine = filteredCropsMat(count,:);
                if dataLine(7) == 0    % if "active" bit turned off
                    continue,          % leave line in matrix empty
                end
                frame = dataLine(2);
                bb = dataLine(3:6);

                if ~offlineCrop_and_not_OnTheFlyFeatureExtraction
                    % ON-THE-FLY IMAGE CROPPING
                    subImage = getFrameAndCrop(testCamera, frame, bb);
                else % if cropped offline
                    subImage = imread([filteredCropsDirectory sprintf('/F%06d.png',count)]);
                end
                % Padding image to 2 per 1 ratio, to match the size of
                % body-part masks
                paddedImage = smartPadImageToBodyPartMaskSize(subImage);            

                % Extracting HSV feature vector (10 bin per channel of each of
                % the 4 parts, totaling 120x1 vector)
                feature = featureExtractionHandle(paddedImage,masks(count,:));

                % RE-ID classification, receives feature vector for test
                % sample, and trainingDataStructure that contains all
                % pertaining to the training samples (more info on createTrainStructure.m).
                dist1toPedsPIDsI = reIdentifierHandle(feature,trainingDataStructure);

                allRMatToSave(count,:) = [dataLine(1:6) dist1toPedsPIDsI];

                % DEBUG VISUALIZATION
                % VISUALIZE OFFLINE CROPPED IMAGE, ONLINE CROPPED IMAGE, PADDED
                % IMAGE, AND BODY-PART MASKS OVERLAYED ON THE PADDED IMAGE
                %figure(234),
                %subplot(1,5,1)
                %imshow(subImage),            title('Online Crop'),
                %
                %FXXXpng = [filteredCropsDirectory '/' sprintf('F%06d.png',count)];
                %if exist(FXXXpng,'file')
                %    subplot(1,4,2)
                %    imshow(imread(FXXXpng))
                %    title('Cropped offline')
                %end
                %
                %subplot(1,5,3)
                %imshow(paddedImage), title('Padded'),
                %
                %subplot(1,5,4)
                %imshow(paddedImage), title('Masked')
                %hold on
                %plotBodyPartMasks(paddedImage,masks(count,:));
                %hold off,
                %
                %subplot(1,5,5)
                %bar(HSV),
                % END DEBUG VISUALIZATION

            end
            close(wbr);
        end
        
        dlmwrite([reIdsDirectory '/allR.txt'],allRMatToSave);
        cprintf('*[1,0,1]',['Saved allR.txt to ' reIdsDirectory '\n'])        
    end
    
return
