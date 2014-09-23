function crop()
    %crop: reads the input images,
    %      reads the detections BB's,
    %      filters the detections BB's based on height and score,
    %      computes which detections have mutual overlap and how much,
    %      computes which detections are Geometrically Fully Visible,
    %      writes the cropped images and the data in the HdaRoot/TestData/Detector/camera??/Crops directory.
    %
    %The output format for the data is:
    %cameraId, frameNumber, x0, y0, width, height, score, overlapRatio, GFV
    %
    %When "recomputeAllCachedInformation" is set, the output directory is cleared before computuing the new results.
    %When "recomputeAllCachedInformation" is false, the function only recomputes the crops which are missing, given the input data.

    declareGlobalVariables,

    %Default parameters
    % if(~exist('minimumScore','var')),    minimumScore  = 0; end;
    % if(~exist('minimumHeight','var')),   minimumHeight = 68; end;
    if(~exist('recomputeAllCachedInformation','var')), recomputeAllCachedInformation = 0; end;

    % offlineCrop_and_not_OnTheFlyFeatureExtraction = 1;
    if ~offlineCrop_and_not_OnTheFlyFeatureExtraction
        display('crop.m: Not creating the cropped images to save on time')
    end
    seqFilesDirectory = [hdaRootDirectory '/hda_image_sequences_matlab'];

    % nTotalRemoved=0;
    for testCamera = testCameras

        fprintf('crop: Working on camera: %d\n',testCamera);

        %Load all detections into memory to compute inter-detection overlap and GFV (Gemoetrically Fully Visible) flag
        localDetectionsDirectory = [thisDetectorDetectionsDirectory sprintf('/camera%02d',testCamera) '/Detections'];
        localCropsDirectoryForText = sprintf('%s/camera%02d/Crops',experimentDataDirectory,testCamera);
        localCropsDirectoryForImages = sprintf('%s/camera%02d/FilteredCrops',experimentDataDirectory,testCamera); %The crops are written directly to this directory to avoid GB of duplication
        if ~exist(localCropsDirectoryForText,'dir'),   mkdir(localCropsDirectoryForText);  end;
        if ~exist(localCropsDirectoryForImages,'dir'), mkdir(localCropsDirectoryForImages);end;
        if(recomputeAllCachedInformation)
            delete([localCropsDirectoryForText   '/info.txt']);
            delete([localCropsDirectoryForText   '/allC.txt']);
            delete([localCropsDirectoryForImages '/F*.png']);
            % Delete old C*.txt files now that we only create one file: allC.txt 
            delete([localCropsDirectoryForText   '/C*.txt']);
        end
        fid = fopen([localCropsDirectoryForText '/info.txt'],'w');
        fprintf(fid,'Crop rectangle information, including the mutual detection overlap value and the Geometrically Fully Visible flag.\n');
        fprintf(fid,'Format: \n');
        fprintf(fid,'camera#, frame#, x0, y0, width, height, score, overlapFraction, GFV\n');
        fclose(fid);
        
        try
            DetMat=dlmread([localDetectionsDirectory '/allD.txt']);
        catch me
            error([me.message '. There doesn''t seem to be any detections for this camera (' ...
                int2str(testCamera) ') did you make a mistake in the test cameras selection?'])
        end
        cprintf('*blue',['Loaded allD.txt from ' localDetectionsDirectory '\n'])

        outputFilesAlreadyThere = true;
        if offlineCrop_and_not_OnTheFlyFeatureExtraction
            for count=1:size(DetMat,1)
                fileName = [localCropsDirectoryForImages sprintf('/F%06d',count) '.png'];
                if(~exist(fileName,'file'))
                    outputFilesAlreadyThere = false;
                end
            end
        end
        if ~exist([localCropsDirectoryForText '/allC.txt'],'file')
            outputFilesAlreadyThere = false;
        end
        if outputFilesAlreadyThere
            if offlineCrop_and_not_OnTheFlyFeatureExtraction
                cprintf('blue','Crops already done (F000000.png and allC.txt)\n')
                cprintf('blue',['Crops at ' localCropsDirectoryForImages '\n'])
                cprintf('blue',['allC.txt at ' localCropsDirectoryForText '\n'])
            else
                cprintf('blue',['Crop file allC.txt already done at ' localCropsDirectoryForText '\n'])
                cprintf('blue','images F*.png not created for time concerns\n')                
                cprintf('blue','(set ''offlineCrop_and_not_OnTheFlyFeatureExtraction'' to 1 in crop.m to create them).\n')
            end            
            continue,
        end



        %Set up image reading stuff
        seqName = sprintf('%s/camera%02d.seq',seqFilesDirectory, testCamera); %MATTEO TODO CHANGE CAM TO CAMERA
        seqReader = seqIo( seqName, 'reader'); % Open the input image sequence
        info = seqReader.getinfo();
        nImages = info.numFrames;
%         seqReader.seek(0);
%         image = seqReader.getframe();
%         [nRows,nCols,nPags] = size(image);
% 
%         %The pointer initially points to image -1, after the first sequReader.next() it points to image 1

        %Process the images
        firstDetectionId = 0; %Points to the first detection of current image. Needed to "remember" the name of the file to write.
        imageNumber =0;
        wbr = waitbar(0, ['Cropping on camera ' int2str(testCamera) ', image frame ' int2str(imageNumber) '/' int2str(nImages)]);
        MatToSave = zeros(size(DetMat,1),size(DetMat,2)+2);
        for imageNumber = 0 : nImages-1
            waitbar(imageNumber/nImages, wbr, ['Cropping on camera ' int2str(testCamera) ', image frame ' int2str(imageNumber) '/' int2str(nImages)]);

            %select detections relative to this frame
            dets=DetMat(DetMat(:,2)==imageNumber,3:end); 

            %If there are no detections, just skip the frame
            if(size(dets,1)>0)
                if offlineCrop_and_not_OnTheFlyFeatureExtraction
                    %Read the image
                    seqReader.seek(imageNumber);
                    image = seqReader.getframe();
                    [nRows,nCols,nPags] = size(image);
                end
                
                %Compute overlap among detections
                [detOverlaps, theseTwoRectanglesOverlap] = computeRectanglesOverlap2(dets);

                %Check which detections are fully visible according to
                %scene geometry and remove all the rest
                GFV=ones(size(dets,1),1);
                bottoms = dets(:,2) + dets(:,4);
                [data,bIndex]=sort(bottoms);
                for alpha=1:size(dets,1)
                    for beta=alpha+1:size(dets,1)
                        if(theseTwoRectanglesOverlap(bIndex(alpha), bIndex(beta)))
                            GFV(bIndex(alpha)) = 0; %the rect's which overlap with something that's lower are not GFV.
                        end
                    end
                end


                %Write cropped images and text files with information
                for detId=1:size(dets,1)

                    %                     % DEBUG show images
                    %                     figure(1),imshow(image);
                    %                     hold on,
                    %                     rectangle('Position', [u0 v0 u1-u0 v1-v0], 'EdgeColor','r','LineWidth',5),
                    %                     rectangle('Position', dets(detId,1:4), 'EdgeColor','g','LineWidth',5),
                    %                     hold off,
                    %                     waitforbuttonpress,

                    if offlineCrop_and_not_OnTheFlyFeatureExtraction
                        x1 = max(round(dets(detId,1)),1);
                        y1 = max(round(dets(detId,2)),1);
                        x2 = min(round(dets(detId,1)+dets(detId,3)),nCols);
                        y2 = min(round(dets(detId,2)+dets(detId,4)),nRows);
                        subImage=image( y1:y2, x1:x2, : );
                    end

                    cropId = firstDetectionId+detId;
                    if offlineCrop_and_not_OnTheFlyFeatureExtraction
                        imageName = sprintf('%s/F%06d.png',localCropsDirectoryForImages,cropId);
                        imwrite(subImage,imageName);
                    end
                    MatToSave(cropId,:) = [DetMat(cropId,1:end),detOverlaps(detId),GFV(detId)];
                end
            end
            firstDetectionId = firstDetectionId + size(dets,1);
        end
        close(wbr);

        dlmwrite([localCropsDirectoryForText '/allC.txt'],MatToSave);
        cprintf('*red',['Saved allC.txt to ' localCropsDirectoryForText '\n'])

    end

return