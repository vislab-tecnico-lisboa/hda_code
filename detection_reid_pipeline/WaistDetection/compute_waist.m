function [waist res1] = compute_waist(iih, distance, normalize)
% function waist = compute_waist(iih)
% 
% Receives integral image, sweeps it vertically, and finds the point which
% maximixes the diffusion difference between the upper and lower part 
% histogram.
% 
% Only looks for maximum between 0.35 and 0.60 (default) percent of the image
% (expected position of the waist in a person detection)
% 
% Dario Figueira <dfigueira@isr.ist.utl.pt>
% 
% Work protected by the Attribution-NonCommercial-ShareAlike 3.0 Unported
% Creative Commons license
% http://creativecommons.org/licenses/by-nc-sa/3.0/

if ~exist('normalize','var')
    normalize = 0;
end
if ~exist('distance','var')
    distance = 'bhattacharyya';
end 

    res1 = zeros(1,size(iih,3));
    start_ =floor(size(iih,3)*0.35);
    end_ = ceil(size(iih,3)*0.60);
    for it=start_:end_ % excluding more
        %lower side                       %upper side
        
        if normalize
            rabohist = normalize_matrix(iih(:,:,size(iih,3)) - iih(:,:,it));
            rabohist2 = normalize_matrix(iih(:,:,it));
        else
            rabohist = iih(:,:,size(iih,3)) - iih(:,:,it);
            rabohist2 = iih(:,:,it);
        end    
        
        if strcmp(distance, 'diffusion')
            res1(it) = diffusion_distance(rabohist,rabohist2);
        elseif strcmp(distance, 'bhattacharyya') % bhattacharyya already force normalizes
            res1(it) = bhattacharyya_mod(rabohist,rabohist2);
        elseif strcmp(distance, 'euclidean')
            res1(it) = norm(rabohist-rabohist2);
        else
            display(['ERROR: ' distance ' is not a valid distance! Choose from: diffusion bhattacharyya euclidean'])
            waist = Inf;
            return;
        end
    end
    % Plot evolution of distances across the person's body
    %figure(234), plot(res1);
    index = local_max_mod(res1);
    index = index(index > start_); %removing upper limit
    index = index(index < end_); %removing lower limit
    if isempty(index)
%         figure(randi(1000)), 
%         plot(res1);
        cprintf('error','ERROR: No local maxima for the waist computation, check for empty image or constant color image. Setting waist to mid-point.\n')
%         title('ERROR: No local maxima for the waist computation, check for empty image or constant color image.')
        waist = round((start_+end_)/2);
        return
    end
    [Y,I] = max(res1(index));
    waist = index(I);

%% TODO: CONSIDER NOT NORMALIZING THE HISTOGRAMS WHEN COMPUTING DISTANCE
%% TODO: TEST DIFFERENT DISTANCES (BHATT..)