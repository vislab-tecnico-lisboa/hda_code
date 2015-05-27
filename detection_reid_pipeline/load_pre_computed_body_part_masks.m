function masks = load_pre_computed_body_part_masks(bodypartmaksksDirectory,nFiles)

    declareGlobalVariables,
    
%     if isempty(featureExtractionMethod)
%         featureExtractionMethod = '4parts';
%     end

    masks = load([bodypartmaksksDirectory '/pmskset4_128x64.mat']);
    masks = masks.pmskset;
    if size(masks,1) ~= nFiles
        error(['Number of masks (' int2str(size(masks,1)) ') not equal to number of filtered crops (' int2str(nFiles) '). Maybe they were computed with crowd detections?'])
    end

    
    if strcmp(featureExtractionMethod, '4parts')
        % part masks in the files are already 4 body-parts, do nothing
    elseif strcmp(featureExtractionMethod, '2parts')
        % load the 2 part masks that join all parts in full-body, and then detected waist
        masks = load([bodypartmaksksDirectory '/pmskset2_128x64.mat']);
        masks = masks.pmskset;
        if size(masks,1) ~= nFiles
            error(['Number of masks (' int2str(size(masks,1)) ') not equal to number of filtered crops (' int2str(nFiles) '). Maybe they were computed with crowd detections?'])
        end
        
        % kinda "backwards" fixing, I saved the 2part masks as doubles
        % instead of logicals, fixing it now
        if ~islogical(masks{1})
            samplemask=masks{1};
            s=whos('samplemask');
            warning(['masks were ' s.class ' instead of logical, re-saving it as logical at ' [bodypartmaksksDirectory '/pmskset2_128x64.mat']]),
            for isample = 1:size(masks,1)
                for ipart = 1:size(masks,2)
                    maskslogical{isample,ipart}=logical(masks{isample, ipart});
                end
            end
            masks = maskslogical;
%             masks = logical(masks);
            pmskset = masks;
            save([bodypartmaksksDirectory '/pmskset2_128x64.mat'],'pmskset'),
        end
        
    elseif strcmp(featureExtractionMethod, 'fullbody')
        [nImg,nParts] = size(masks);
        for imageIt = 1:nImg
            fullmask = masks{imageIt,1} | masks{imageIt,2} | masks{imageIt,3} | masks{imageIt,4};
            pmskset_full{imageIt,1} = fullmask;
        end
        masks = pmskset_full;        
    elseif strcmp(featureExtractionMethod, '6rectangles')
        masks6horizontalbars = Set_6_masks_6_horizontal_bars_in_an_128x64_image();
        [nImg,nParts] = size(masks);        
        for imageIt = 1:nImg
            assert(size(masks{imageIt,1},1)==128,['need to program for masks of different sizes, such as: ' int2str(size(masks{imageIt,1},1))]),
            pmskset_6bars{imageIt,1} = masks6horizontalbars{1};
            pmskset_6bars{imageIt,2} = masks6horizontalbars{2};
            pmskset_6bars{imageIt,3} = masks6horizontalbars{3};
            pmskset_6bars{imageIt,4} = masks6horizontalbars{4};
            pmskset_6bars{imageIt,5} = masks6horizontalbars{5};
            pmskset_6bars{imageIt,6} = masks6horizontalbars{6};
        end
        masks = pmskset_6bars;
    elseif strcmp(featureExtractionMethod, '6parts')
        % load the 2 part masks that join all parts in full-body, and then detected waist
        masks = load([bodypartmaksksDirectory '/pmskset6_128x64.mat']);
        masks = masks.pmskset;
        if size(masks,1) ~= nFiles
            error(['Number of masks (' int2str(size(masks,1)) ') not equal to number of filtered crops (' int2str(nFiles) '). Maybe they were computed with crowd detections?'])
        end
        
    else
        error(['unrecognized featureExtractionMethod ' featureExtractionMethod])
    end
    
        