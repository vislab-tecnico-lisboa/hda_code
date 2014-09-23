function createallDetections_plusGT_and_NoCrowds(testCameras, hdaRootDirectory, thisDetectorDetectionsDirectory, recomputeAllCachedInformation) %  reIdentifierName
% createallDetectionsPlusGT
% 
% Create allDetectionsPlusGT.txt file at the Detections folder that
% contains the same as allD.txt plus the corresponding person ID for each
% detection. Person ID is determined by the ground-truth bounding box that
% has greater degree of overlap with each detection. If one detection has
% less than 0.5 overlap ratio (Pascal VOC criterion) it receives the false
% positive ID (999).
% 
% Needed for  FgetDSET_F0000pngtxt.m called from Run_HDA_experiments.m

    for testCamera = testCameras
        %%
        fprintf('createallDetectionsPlusGT: Working on camera: %d\n',testCamera);
        
        detectionsDirectory = [thisDetectorDetectionsDirectory sprintf('/camera%02d',testCamera) '/Detections'];
%         reIdsDirectory         = [experimentDataDirectory sprintf('/camera%02d/ReIds',       testCamera) reIdentifierName];
%         reIdsAndGtDirectory    = [experimentDataDirectory sprintf('/camera%02d/ReIdsAndGts', testCamera) reIdentifierName];
         
%         if ~exist(reIdsAndGtDirectory,'dir'), mkdir(reIdsAndGtDirectory); end;
        if(recomputeAllCachedInformation)
%             delete([reIdsAndGtDirectory '/info.txt']);
%             delete([reIdsAndGtDirectory '/allG.txt']);
            delete([detectionsDirectory '/allDetections_noCrowds.txt']);
            delete([detectionsDirectory '/allDetectionsPlusGT.txt']);
            delete([detectionsDirectory '/infoallDetectionsPlusGT.txt']);
        end
        if exist([detectionsDirectory '/allDetectionsPlusGT.txt'],'file')
            cprintf('blue',['allDetectionsPlusGT.txt already exists at ' detectionsDirectory '\n']),
            continue,
        end
        fid = fopen([detectionsDirectory '/infoallDetectionsPlusGT.txt'],'w');
        fprintf(fid,'Detection information and Ground Truth ID.\n');
        fprintf(fid,'Format: \n');
        fprintf(fid,'camera#, frame#, x, y, w, h, score, realId.\n');
        fclose(fid);

        %Read GT file (VBB)
        GTName = [hdaRootDirectory '/hda_annotations' sprintf('/cam%02d_rev1.txt',testCamera)];
        GTMat = vbb('vbbLoadTxt',GTName);
        
        % nameList=dir([reIdsDirectory '/R*.txt']);
        DetMat=dlmread([detectionsDirectory '/allD.txt']);
        nDets=size(DetMat,1);
        %Work on one detectition file at a time
        wbr = waitbar(0, ['createallDetectionsPlusGT on camera ' int2str(testCamera) ', det 0/' int2str(nDets)]);
        MatToSave = zeros(nDets,size(DetMat,2)+1);
        crowd = zeros(nDets,1);
        for det=1:nDets
            waitbar(det/nDets, wbr, ['createallDetectionsPlusGT on camera ' int2str(testCamera) ', det ' int2str(det) '/' int2str(nDets)]);
            dataLine = DetMat(det,:);
            if min(dataLine==zeros(size(dataLine))) % if line is "empty" (all zeros) 
                continue,
            end
            frame = dataLine(2);
            %Select the GT data for this image
%             try
                gt=GTMat.objLists{1,frame+1}; 
%             catch me
%                 display(['ERROR: ' me.message ]),
%                 display(['Min-max number of frames in DetMat: [' num2str(min(DetMat(:,2))) '  ' num2str(max(DetMat(:,2))) ']'])
%                 display(['Size of objLists: ' num2str(size(GTMat.objLists))])
%                 MatToSave = MatToSave(1:end-1,:);
%                 continue,
%             end

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
                if isempty(label) && ( strcmp('crowd', GTMat.objLbl{1,gt(1,maxOvlpId).id}) || strcmp('personUnk', GTMat.objLbl{1,gt(1,maxOvlpId).id}) )
                    crowd(det) = 1;
                    label = -1;
                end
            end
            
            MatToSave(det,:) = [dataLine, label];
            
        end
        close(wbr);
        
        MatToSave_noCrowd = MatToSave(~crowd,1:end-1);
        
        dlmwrite([detectionsDirectory '/allDetectionsPlusGT.txt'],MatToSave);        
        cprintf('*red',['Saved allDetectionsPlusGT.txt to ' detectionsDirectory '\n'])        
        dlmwrite([detectionsDirectory '/allDetections_noCrowds.txt'],MatToSave_noCrowd);
        cprintf('*red',['Saved allDetections_noCrowds.txt to ' detectionsDirectory '\n'])
        if sum(crowd)
            movefile([detectionsDirectory '/allD.txt'],[detectionsDirectory '/allDetections_withCrowd.txt'])
            cprintf('*red',['Backed up original allD to allDetections_withCrowd.txt in ' detectionsDirectory '\n'])
        else
            display(['No crowd labels in this camera'])
        end
        copyfile([detectionsDirectory '/allDetections_noCrowds.txt'],[detectionsDirectory '/allD.txt'])
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
