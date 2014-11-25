function allGMatToSave = GTandDetMatcher(mode)
%GTANDDETMATCHER associates GT labels to ReId BB's.
% Reads GT labels, reads ReId results, computes the overlap between each
% (GT BB, ReId BB) in a frame, and associates each ReId BB to the GT BB
% with wich it has the highest overlap. GT labels are read from VBB files,
% ReId results contain information on the position and size of the BB's. 
% ReId BB's with less than 50% overlap (PASCAL VOC criterion) with any GT
% BB are considered False Positives and are associated with the FP label: 999.

	declareGlobalVariables,

    if ~exist('mode','var')
        mode = 'normal';
    end
    
    for testCamera = testCameras
        fprintf('gtAndDetMatcher: Working on camera: %d\n',testCamera);
        
        reIdsDirectory         = [experimentDataDirectory sprintf('/camera%02d',       testCamera) '/ReIds_' reIdentifierName];
        reIdsAndGtDirectory    = [experimentDataDirectory sprintf('/camera%02d', testCamera) '/ReIdsAndGT_' reIdentifierName];
         
        if ~exist(reIdsAndGtDirectory,'dir'), mkdir(reIdsAndGtDirectory); end;
        if(recomputeAllCachedInformation)
            warning('off','MATLAB:DELETE:FileNotFound')
            delete([reIdsAndGtDirectory '/info.txt']);
            delete([reIdsAndGtDirectory '/allG.txt']);
            warning('on','MATLAB:DELETE:FileNotFound')
        end
        %if exist([reIdsAndGtDirectory '/allG.txt'],'file')
        %    cprintf('blue',['allG.txt already exists at ' reIdsAndGtDirectory '\n']),
        %    % TODO? MAYBE DLMREAD HERE TO PRODUCE OUTPUT?
        %    continue,
        %end
        fid = fopen([reIdsAndGtDirectory '/info.txt'],'w');
        fprintf(fid,'Ground Truth ID and list of estimated ID''s for each crop, sorted according to rank.\n');
        fprintf(fid,'Format: \n');
        fprintf(fid,'camera#, frame#, realId, estimatedId1, estimatedId2, ...\n');
        fclose(fid);

        %Read GT file (VBB)
        GTName = [hdaRootDirectory '/hda_annotations' sprintf('/cam%02d.txt',testCamera)];
        GTMat = vbb('vbbLoadTxt',GTName);
        
        if strcmp(mode,'normal')
            reIdsMat = dlmread([reIdsDirectory '/allR.txt']);
        elseif strcmp(mode,'detections')
            localDetectionsDirectory = [thisDetectorDetectionsDirectory sprintf('/camera%02d',testCamera) '/Detections'];
            reIdsMat = dlmread([localDetectionsDirectory '/allD.txt']);
        end
        nReIds=size(reIdsMat,1);
        %Work on one detectition file at a time
        wbr = waitbar(0, ['gtAndDetMatcher on camera ' int2str(testCamera) ', image 0/' int2str(nReIds)]);
        dividerWaitbar=10^(floor(log10(nReIds))-1); % Limiting the access to waitbar
        % reIdsMat has         : camera#, frame#, x0, y0, width, height, ranked-list 
        % allG supposed to have: camera#, frame#, realId, ranked-list
        allGMatToSave = zeros(nReIds,size(reIdsMat,2)-3);
        for image=1:nReIds
            if (round(image/dividerWaitbar)==image/dividerWaitbar) % Limiting the access to waitbar
                waitbar(image/nReIds, wbr, ['gtAndDetMatcher on camera ' int2str(testCamera) ', image ' int2str(image) '/' int2str(nReIds)]);
            end
            dataLine = reIdsMat(image,:);
            if min(dataLine==zeros(size(dataLine))) % if line is "empty" (all zeros) 
                continue,
            end
            frame = dataLine(2);

            %Select the GT data for this image
            gt=GTMat.objLists{1,frame+1}; 
            isFalsePositive = 1;
            overlap =[];
            for gtId=1:size(gt,2) 
                [match, cost] = computeBbMatch( gt(1,gtId).pos, dataLine(3:6), 0.5); %match = 0 if there is no overlap, 1 otherwise
                overlap(gtId) = 1-cost;
                if(match), isFalsePositive = 0; end               
            end    
            if(isFalsePositive)
              label=999;
            else
              [value, maxOvlpId] = max(overlap);  
              label = GTMat.objLbl{1,gt(1,maxOvlpId).id};  
              label = sscanf(label,'person%d');              
            end
            label2 = selectGTdataOfImage(GTMat, dataLine(3:6), frame);
            assert(label==label2)
            
            allGMatToSave(image,:) = [dataLine(1),dataLine(2),label,dataLine(7:end)];
            
        end
        close(wbr);
        
        if strcmp(mode,'normal')
            dlmwrite([reIdsAndGtDirectory '/allG.txt'],allGMatToSave);
            cprintf('*[1,0,1]',['Saved allG.txt to ' reIdsAndGtDirectory '\n'])
        end
    end

return


