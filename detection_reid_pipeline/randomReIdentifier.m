function randomReIdentifier()
%Reads filtered detections and generated ReId output randomly selecting the people Id for the ranks

declareGlobalVariables,

trainingDataStructure = createTrainStructure();

for testCamera = testCameras
    fprintf('randomReIdentifier: Working on camera: %d\n',testCamera);
    
    % Filter out test camera from training data structure
    % No need anymore, using trainCameras list to create the structure
    % trainDataStructNoTestCamera = trainingDataStructure([trainingDataStructure.camera] ~= testCamera);
    % numberTrainingPedestrians = length(unique([trainDataStructNoTestCamera.personId]));
    %For randomization
    personIds=unique([trainingDataStructure.personId]);
    
    %Work on one file at a time
    filteredCropsDirectory = [experimentDataDirectory sprintf('/camera%02d',testCamera) '/FilteredCrops'];
    reIdsDirectory         = [experimentDataDirectory sprintf('/camera%02d',testCamera) '/ReIds' reIdentifierName];
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
    fprintf(fid,'Detections that were filtered out, and thus have their "active" bit to zero, are not processed and an empty file is created\n');
    fprintf(fid,'Format: \n');
    fprintf(fid,'camera#, frame#, x0, y0, width, height, estimatedId1, estimatedId2, ...\n');
    fclose(fid);
    
    filteredCropsMat = dlmread([filteredCropsDirectory '/allF.txt']);
    nDetections=size(filteredCropsMat,1);
    
    bodypartmaksksDirectory      = [thisDetectorDetectionsDirectory sprintf('/camera%02d',testCamera) '/Detections'];
    masks = load([bodypartmaksksDirectory '/pmskset4originalSize.mat']);
    masks = masks.pmskset;
    if size(masks,1) ~= nDetections
        warning(['Number of masks (' int2str(size(masks,1)) ') not equal to number of filtered crops (' int2str(nDetections) ')?'])
    end
    %assert(size(masks,1)==nFiles,'Number of masks not equal to number of filtered crops?')

    wbr = waitbar(0, ['Random ReIdentifying on camera ' int2str(testCamera) ', image 0/' int2str(nDetections)]);
    MatToSave = zeros(nDetections,6+length(personIds));
    for count=1:nDetections
        waitbar(count/nDetections, wbr, ['Random ReIdentifying on camera ' int2str(testCamera) ', image ' int2str(count) '/' int2str(nDetections)]);
        dataLine = filteredCropsMat(count,:);
        frame = dataLine(2);
        bb = dataLine(3:6);
        if dataLine(7) == 0    % if "active" bit turned off
            continue,          % leave line in matrix empty
        end
        
        % CREATING ON-THE-FLY IMAGE CROPPING
        if ~offlineCrop_and_not_OnTheFlyFeatureExtraction
            %Set up image reading stuff
            seqFilesDirectory = [hdaRootDirectory '/hda_image_sequences_matlab'];
            seqName = sprintf('%s/camera%02d.seq',seqFilesDirectory, testCamera); %MATTEO TODO CHANGE CAM TO CAMERA
            seqReader = seqIo( seqName, 'reader'); % Open the input image sequence
            %Read the image
            seqReader.seek(frame);
            image = seqReader.getframe();
            delete(['tmp_' sprintf('camera%02d',testCamera) '_*.jpg' ])
            [nRows,nCols,nPags] = size(image);
            %Crop
            x1 = max(round(bb(1)),1);
            y1 = max(round(bb(2)),1);
            x2 = min(round(bb(1)+bb(3)),nCols);
            y2 = min(round(bb(2)+bb(4)),nRows);
            subImage=image( y1:y2, x1:x2, : );
            figure(234),
            subplot(1,4,1)
            imshow(subImage),            title('Online Crop'),
%             subplot(1,4,2)
%             imshow(imread([filteredCropsDirectory '/' sprintf('F%06d.png',count)]))
%             title('Cropped offline')
            subplot(1,4,3)
            paddedImage = smartPadImageToBodyPartMaskSize(subImage);
            imshow(paddedImage), title('Padded'),
            % TODO: include sample code masking padded image with
            % body-masks 
            % Show part masks as multi-colored outline on top of person image,
            subplot(1,4,4)
            imshow(paddedImage), title('Masked')
            hold on
            for partIt = 1:4
                B = bwboundaries(masks{count,partIt});
                switch partIt
                    case 1 %head
                        color = 'b';
                    case 2 %torso
                        color = 'w';
                    case 3 %thighs
                        color = 'm';
                    case 4 %fore-legs
                        color = 'r';
                end
                for k = 1:length(B)
                    boundary = B{k};
                    plot(boundary(:,2), boundary(:,1), color, 'LineWidth', 3)
                end
            end
            hold off,
            
        end
        
        %Randomly choose the person ID's to be associated to this particular detection
        rankedPersons=personIds(randperm(length(personIds)));
        
        MatToSave(count,:) = [dataLine(1:6) rankedPersons];
    end
    close(wbr);
    
    dlmwrite([reIdsDirectory '/allR.txt'],MatToSave);
    cprintf('*red',['Saved allR.txt to ' reIdsDirectory '\n'])
end

return