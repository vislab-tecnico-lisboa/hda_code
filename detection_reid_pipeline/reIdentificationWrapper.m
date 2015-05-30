function reIdentificationWrapper()
%% Reads filtered detections and generated ReId output 
% TODO: MORE COMMENTS
    
	declareGlobalVariables,

%     trainingDataStructure = createTrainStructure();    
    trainingDataStructure = createTrainStructure_loading_images_from_seq_files();    
    trainSpidVector = [trainingDataStructure.personId];
    unique_trainSpid = unique([trainingDataStructure.personId]);
    nPed = length(unique_trainSpid);
        
    for testCamera = testCameras
        %% 
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
        if strcmp(featureExtractionMethod, '2parts')
            Create_2parts_body_part_masks_in_reIdentificationWrapper,
        end
        masks = load_pre_computed_body_part_masks(bodypartmaksksDirectory,nFiles);

        
        if classifierNeedsAllTestData
            % Special case: algorithms that take as input the whole test set
            % before outputting the re-identification classifications
            
            testDataStructure = createTestStructure(testCamera);
            filteredTestStruct = testDataStructure(logical(filteredCropsMat(:,7)));

            % if we have a function
            rankedList = reIdentifierHandle(trainingDataStructure,filteredTestStruct,filteredCropsMat); % OUTPUT: rankedList
            % if we have a script
            %eval(reIdentifierName)
            
            allRMatToSave = zeros(nFiles,6+nPed);
            allRMatToSave(logical(filteredCropsMat(:,7)),1:6) = filteredCropsMat(logical(filteredCropsMat(:,7)),1:6);
            allRMatToSave(logical(filteredCropsMat(:,7)),7:end) = rankedList'; 
        else
            % Regular case, re-identifier takes one test sample and outputs one
            % classification vector
            if waitbarverbose
                wbr = waitbar(0, ['RE-ID on camera ' int2str(testCamera) ', det 0/' int2str(nFiles)]);
            end
            allRMatToSave = zeros(nFiles,6+nPed);
            for count=1:nFiles
                if waitbarverbose
                    waitbar(count/nFiles, wbr, ['RE-ID on camera ' int2str(testCamera) ', det ' int2str(count) '/' int2str(nFiles)]);
                end
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
                %                 figure(1321), imshow( paddedImage ),
                %                 hold on
                %                 plotBodyPartMasks(paddedImage,masks(count,:));
                %                 hold off,

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
                %                 figure,
                %                 subplot(1,2,1)
                % %                 imshow(subImage),            title('Online Crop'),
                % %                 
                % %                 FXXXpng = [filteredCropsDirectory '/' sprintf('F%06d.png',count)];
                % %                 if exist(FXXXpng,'file')
                % %                    subplot(1,4,2)
                % %                    imshow(imread(FXXXpng))
                % %                    title('Cropped offline')
                % %                 end
                % %                 
                % %                 subplot(1,5,3)
                % %                 imshow(paddedImage), title('Padded'),
                % %                 
                %                 subplot(1,2,1)
                %                 imshow(paddedImage), title('Masked')
                %                 hold on
                %                 plotBodyPartMasks(paddedImage,masks(count,:));
                %                 hold off,
                %                 
                %                 subplot(1,2,2)
                %                 bar(feature),
                %                 waitforbuttonpress,
                % 
                % END DEBUG VISUALIZATION

            end
            if waitbarverbose
                close(wbr);
            end
        end
        
        dlmwrite([reIdsDirectory '/allR.txt'],allRMatToSave);
        cprintf('*[1,0,1]',['Saved allR.txt to ' reIdsDirectory '\n'])        
    end
    
return
