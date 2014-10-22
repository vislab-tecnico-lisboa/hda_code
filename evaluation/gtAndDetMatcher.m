function GTandDetMatcher()
%GTANDDETMATCHER associates GT labels to ReId BB's.
% Reads GT labels, reads ReId results, computes the overlap between each
% (GT BB, ReId BB) in a frame, and associates each ReId BB to the GT BB
% with wich it has the highest overlap. GT labels are read from VBB files,
% ReId results contain information on the position and size of the BB's. 
% ReId BB's with less than 50% overlap (PASCAL VOC criterion) with any GT
% BB are considered False Positives and are associated with the FP label: 999.

	declareGlobalVariables,

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
        if exist([reIdsAndGtDirectory '/allG.txt'],'file')
            cprintf('blue',['allG.txt already exists at ' reIdsAndGtDirectory '\n']),
            continue,
        end
        fid = fopen([reIdsAndGtDirectory '/info.txt'],'w');
        fprintf(fid,'Ground Truth ID and list of estimated ID''s for each crop, sorted according to rank.\n');
        fprintf(fid,'Format: \n');
        fprintf(fid,'camera#, frame#, realId, estimatedId1, estimatedId2, ...\n');
        fclose(fid);

        %Read GT file (VBB)
        GTName = [hdaRootDirectory '/hda_annotations' sprintf('/cam%02d.txt',testCamera)];
        GTMat = vbb('vbbLoadTxt',GTName);
        
        reIdsMat = dlmread([reIdsDirectory '/allR.txt']);
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
            
            allGMatToSave(image,:) = [dataLine(1),dataLine(2),label,dataLine(7:end)];
            
        end
        close(wbr);
        
        dlmwrite([reIdsAndGtDirectory '/allG.txt'],allGMatToSave);        
        cprintf('*red',['Saved allG.txt to ' reIdsAndGtDirectory '\n'])
    end

return


function [match cost] = computeBbMatch( r1, r2, threshold)
% r = [u0, v0, width, height]
% threshold should be a value between 0 and 1, typically 0.5

      %Do r1 and r2 intersect? Check if you can define a rectangle which is the intersection of the two.
      u0Int = max( r1(2), r2(2) ); %rightmost left edge
      v0Int = max( r1(1), r2(1) ); %lower top edge
      u1Int = min( r1(2) + r1(4), r2(2) +r2(4) ); %leftmost right edge
      v1Int = min( r1(1) + r1(3), r2(1) +r2(3) ); %upper bottom edge
      
      if( ( u0Int < u1Int ) && ( v0Int < v1Int ) ) %YES, intersection
        overlapArea = (u1Int - u0Int) * (v1Int - v0Int);
        unionArea = r1(3)*r1(4) + r2(3)*r2(4) - overlapArea;
        if( (overlapArea/unionArea) >= threshold)
          match = true;
          cost  = (unionArea-overlapArea)/unionArea; %Encodes how bad the match is. NonOverlap/Union.
        else
          match = false;
          cost  = inf;
        end    
      else
        overlapArea = 0;
        match = false;
        cost  = inf;
      end  
      
return
