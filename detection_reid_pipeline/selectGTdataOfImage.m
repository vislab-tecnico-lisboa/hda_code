function label = selectGTdataOfImage(GTMat, BB, frame)
%Select the GT data for this image
gt=GTMat.objLists{1,frame+1};

isFalsePositive = 1;
overlap =[];
for gtId=1:size(gt,2)
    [match, cost] = computeBbMatch( gt(1,gtId).pos, BB, 0.5); %match = 0 if there is no overlap, 1 otherwise
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
