function filterOccluded()
%filterOccluded:
%Reads the information on the cropped images and adds a flag
%indicating whether the crop should be using for testing a RE-ID system.
%The filtering is currently based on the inter-occlusion ratio of each crop.
%
%When "recomputeAllCachedInformation" is set, the output directory is
%cleared before computuing the new results.
%When "recomputeAllCachedInformation" is false, the function still
%performs all the computations, but only creates the output files
%which are missing. (skipping some computations would not save time).

    declareGlobalVariables,

%     if ~exist('useMutualOverlapFilter','var')
%         useMutualOverlapFilter = 1;
%     end

        
    
    for testCamera = testCameras
        if ~useMutualOverlapFilter
            displayString = ['Setting active flag to 1 on camera ' int2str(testCamera)];
        else
            displayString = ['Filtering on camera ' int2str(testCamera) ];
        end
        display([displayString ' ']),
        
        cropsDirectory = sprintf('%s/camera%02d/Crops',experimentDataDirectory,testCamera);
        filteredCropsDirectory = sprintf('%s/camera%02d/FilteredCrops',experimentDataDirectory,testCamera);
        if(~exist(filteredCropsDirectory,'dir')), mkdir(filteredCropsDirectory); end;
        if(recomputeAllCachedInformation)
            delete([filteredCropsDirectory '/info.txt']);
            %This function does not delete the cropped images, as those are responsibility of the "crop.m" function
            delete([filteredCropsDirectory '/allF.txt']);
            % Delete the old F*.txt files now that we only create one file: allF.txt 
            delete([filteredCropsDirectory '/F*.txt']);
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

        cropsMat = dlmread([cropsDirectory '/allC.txt']);
        nFiles=size(cropsMat,1);
        wbr = waitbar(0, [displayString ', image 0/' int2str(nFiles)]);
        % Work on one file at a time
        MatToSave = zeros(nFiles,7);
        for count=1:nFiles
            waitbar(count/nFiles, wbr, [displayString ', image ' int2str(count) '/' int2str(nFiles)]);
            dataLine = cropsMat(count,:);
            confidenceScore = dataLine(7);
            overlap = dataLine(8);
            GeometricallyFullyVisible = dataLine(9);
            % If user does not wish to use overlap filter put all active flags to 1
            active = -1;
            if(~useMutualOverlapFilter)
                active = 1;
            % If below overlap threshold, not occluded, put active flag to 1    
            elseif overlap<=maximumOcclusionRate
                active = 1;
            % If above overlap threshold, but with GFV (fully visible flag) to 1, not occluded, put active flag to 1    
            elseif overlap>maximumOcclusionRate && GeometricallyFullyVisible==1
                active = 1;
            % If above overlap threshold, and with GFV to zero, occluded, put active flag to 0    
            elseif overlap>maximumOcclusionRate && GeometricallyFullyVisible==0
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
                
            MatToSave(count,:) = [dataLine(1:6), active]; 
            
        end
        close(wbr);
        
        dlmwrite([filteredCropsDirectory '/allF.txt'],MatToSave);
        cprintf('*red',['Saved allF.txt to ' filteredCropsDirectory '\n'])
    end
return
