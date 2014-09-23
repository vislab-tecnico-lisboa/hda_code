%Filter out detections that have a score under the threshold
function [dets,nRemoved] = filterDets(dets, minimumScore, minHeight)

    keep=ones(size(dets,1),1);
    for(a=1:size(dets,1))
        if( (dets(a,5)<minimumScore) || (dets(a,4)<minHeight) )
            keep(a)=0;
        end    
    end    
    %fprintf('I''m keeping only %d detections. ',sum(keep));
    nRemoved=size(dets,1) - sum(keep);
    if(nRemoved>0)
        fprintf('removing!\n');
    end
    %fprintf('I''m removing %d detections. ',nRemoved);
    dets = dets(logical(keep),:);
end
