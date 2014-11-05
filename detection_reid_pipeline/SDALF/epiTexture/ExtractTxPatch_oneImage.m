function TxPatch = ExtractTxPatch_oneImage(img, KernelMap, fullBodyMask, MiddleTorso,Waist)
% 
% 
% 

%% Global parameters (PUT THEM SOMEWHERE GLOBAL?)
% Imgs parameters (for different tests)
SUBfac  = 1;    % subsampling factor <==== CHANGE TO 0.5 WHEN USING ETHZ DATASET!!!
H = ceil(128*SUBfac); W = ceil(64*SUBfac); % NORMALIZED dimensions

% RHSP parameters
N       = 30;	 % number of patches
fac     = [0,0;		% patches dim. (head is NOT USED!)
    12,10;			%(torso)
    10,8]*SUBfac;	%(legs)
variance     = 3*SUBfac;     % dimension variance
NTrans      = 20;       % number of transformations (along y axis)
DIM_OP      = [35,35]*SUBfac;  % dim. local cross-correlation
Thresh_entr = 13;     % entropy thresholdings
Thresh_CC	= 0.4;		% crosscorrelation thresholding
mapping     = getmapping(8,'u2');			  % LBP param. (for CLUSTERING)
MSpar       = [10,25,45*ones(1,mapping.num)]; % MeanShift bandwidth

plotY = 0;

%%
img_hsv     =   rgb2hsv(img);
tmp         =   img_hsv(:,:,3);
tmp         =   histeq(tmp); % Color Equalization
img_hsv     =   cat(3,img_hsv(:,:,1),img_hsv(:,:,2),tmp);
warning('NOT USING COLOR EQUALIZATION, SHOULD TEST TO SEE IF IT''S BETTER')
img_gray	= rgb2gray(img);

Map = KernelMap.*double(fullBodyMask);

%         if plotY
%             hs1 = subplot(maxplot*2/12,12,ii); imshow(img);hold on;
%             plot([1,W],[Waist,Waist],'b','LineWidth',2);
%             plot([1,W],[HDanti(i),HDanti(i)],'b','LineWidth',2);
%             plot([MiddleTorso,MiddleTorso],[HDanti(i),Waist],'b','LineWidth',2);
%             plot([LEGsim(i),LEGsim(i)],[Waist+1,H],'b','LineWidth',2);
%         end

div = uint16([1,MiddleTorso+1,Waist+1;
    MiddleTorso,    Waist,H]);
ppart = 1;
% For the torso and the legs (2 parts)
for part = 2:size(div,2) % NO head
    
    img_part = img_gray(div(1,part):div(2,part),:);
    R = [1,1,fliplr(size(img_part))-1]; % [x,y,dimx,dimy] = [c,r,dimc,dimr] = [w,h,dimw,dimh]
    
    % take some random patches in the image part
    patches =  wins_SG_rnd(R,N,fac(part,:),variance,Map(div(1,part):div(2,part),:),double(fullBodyMask));
    
    if ~isempty(patches)
        
        patches(:,1:2) =  uint16(patches(:,1:2)) + repmat([0,div(1,part)-1],size(patches,1),1);
        
        % GraY hist entropy of the patch computation
        for p = 1:size(patches,1)
            % histogram of entrophy of patches of this image
            histo_entropy(p,ppart)  = entropy(img(patches(p,2):patches(p,2)+patches(p,4),patches(p,1):patches(p,1)+patches(p,3),1)) ...
                + entropy(img(patches(p,2):patches(p,2)+patches(p,4),patches(p,1):patches(p,1)+patches(p,3),2)) ...
                + entropy(img(patches(p,2):patches(p,2)+patches(p,4),patches(p,1):patches(p,1)+patches(p,3),3));
            mem_patch(p,:,ppart) = patches(p,:);
        end
        
        for p = 1:size(patches,1)
            ptcs_t = cell(NTrans,1);
            patch = img_gray(patches(p,2):patches(p,2)+patches(p,4),patches(p,1):patches(p,1)+patches(p,3));
            
            ptcs_t = ptcs_yTrans(patch,NTrans); % patch transformations
            
            patch_op  =  [floor(patches(p,1)-(DIM_OP(1)-patches(p,3))/2) floor(patches(p,2)-(DIM_OP(2)-patches(p,4))/2) DIM_OP(1) DIM_OP(2)];
            patch_op  =	 bbox_exceedes(double(patch_op),H,W);
            img_local =  img_gray(patch_op(2):patch_op(2)+patch_op(4),patch_op(1):patch_op(1)+patch_op(3));
            
            %                 if plotY
            %                     rectangle('Position',patches(p,:));
            %                 end
            
            % Normalized Cross Correlation (NCC)
            if histo_entropy(p,ppart)>Thresh_entr
                if plotY
                    rectangle('Position',patches(p,:),'EdgeColor',[1 0 0]);
                end
                map_ncc = abs(normxcorr2(patch,img_local)); % (original patch)
                map_ncc = map_ncc(ceil((size(patch,1))/2):ceil(size(img_local,1)+(size(patch,1))/2)-1,...
                    ceil((size(patch,2))/2):ceil(size(img_local,2)+(size(patch,2))/2)-1);
            else
                map_ncc = zeros(size(img_local));
            end
            for t=1:length(ptcs_t);
                if sum(ptcs_t{t}(:)>0) && histo_entropy(p,ppart)>Thresh_entr ...
                        && ~all(ptcs_t{t}(:) == ptcs_t{t}(1,1))
                    
                    tmp = abs(normxcorr2(ptcs_t{t},img_local)); % (transformed patch)
                    tmp = tmp(ceil((size(ptcs_t{t},1))/2):ceil(size(img_local,1)+(size(ptcs_t{t},1))/2)-1,...
                        ceil((size(ptcs_t{t},2))/2):ceil(size(img_local,2)+(size(ptcs_t{t},2))/2)-1);
                    map_ncc = map_ncc + tmp;
                    
                end
            end
            map_ncc = map_ncc/(NTrans+1); % normalization
            MNCC{p,ppart} = map_ncc;
            w_ncc(p,ppart) = sum(abs(map_ncc(:)))/numel(img_local);
            
            % CC thresholding and connected component analysis
            thr_map_cc = (map_ncc>Thresh_CC);
            area_ncctmp = regionprops(bwlabel(thr_map_cc),'Area');
            if ~isempty(area_ncctmp)
                area_ncc(p,ppart) = 1-max(struct2array(area_ncctmp))/numel(map_ncc); % max normalized area
            else
                area_ncc(p,ppart) = 0;
            end
            
            tmpPATCH{p} = img(patches(p,2):patches(p,2)+patches(p,4),patches(p,1):patches(p,1)+patches(p,3),:);
            
        end
        
        %% maximally-texturized patch computation (ranking by NCC of the first K high-entropy patches)
        [v,order]	= sort(histo_entropy(:,ppart),'descend'); % entropy sorting
        [v,order2]	= sort(area_ncc(order,ppart),'descend'); % NCC sorting
        ep = 1;
        for p = 1:size(patches,1)
            if histo_entropy(order(order2(p)),ppart)>Thresh_entr  ...
                    && w_ncc(order(order2(p)),ppart)>0
                epitome.patch{ep} = tmpPATCH{order(order2(p))};
                epitome.entr{ep}  = histo_entropy(order(order2(p)),ppart);
                epitome.w_ncc{ep} = area_ncc(order(order2(p)),ppart);
                epitome.pos{ep}   = mem_patch(order(order2(p)),:,ppart);
                epitome.thrCC{ep} = MNCC{order(order2(p)),ppart};
                epitome.areaCC{ep}= area_ncc(order(order2(p)),ppart);
                
                % LBP histogram
                lbph = lbp(epitome.patch{ep}, 1,8,mapping, 'h');
                
                % patch centroid
                ctr = double([epitome.pos{ep}(1)+epitome.pos{ep}(3)/2,...
                    epitome.pos{ep}(2)+epitome.pos{ep}(4)/2]);
                BBox(ep,:) = epitome.pos{ep};
                
                data(:,ep) = [ctr';lbph']; % justapposition of data
                
                ep = ep + 1;
            end
        end
        try
            epitome;
        catch % if no epitome is found
            epitome.patch = [];
        end
        
        %% MS Clustering
        if ~isempty(epitome.patch)
            [clust_res,centres]= MS_Clustering2(data',MSpar,'Uniform',[length(ctr),length(lbph)],2);
            K = max(clust_res);
            
            if K == 0
                warning('DEBUG')
            end
            
            % 1-NN to select representative element
            if K~=0
                for k = 1:K
                    inds = find(clust_res == k);
                    if length(inds)>1
                        D = squareform(pdist([data(:,inds)';centres(k,:)]));
                        D = D(1:size(data(:,inds),2),size(data(:,inds),2)+1:end);
                        [v minind] = min(D);
                        rap(k) = inds(minind);
                        dim_cluster(k) = length(inds);
                    else
                        rap(k) = -1; % eliminate single-element clusters
                        dim_cluster(k) = -1;
                    end
                end
            else
                rap = repmat(-1,size(data,2));
                
                warning('No clusters were found by MS_Clustering2, so setting max_txpatch(part) to empty')
                max_txpatch(part).patch	= [];
                max_txpatch(part).entr	= [];
                max_txpatch(part).w_ncc	= [];
                max_txpatch(part).pos	= [];
                max_txpatch(part).lbph	= [];
                max_txpatch(part).numel	= [];
            end
        end
        
        ep = 1;
        try
            for k = 1:length(rap)
                if rap(k)>0
                    max_txpatch(part).patch{ep}	= epitome.patch{rap(k)};
                    max_txpatch(part).entr{ep}	= epitome.entr{rap(k)};
                    max_txpatch(part).w_ncc{ep}	= epitome.w_ncc{rap(k)};
                    max_txpatch(part).pos{ep}		= epitome.pos{rap(k)};
                    max_txpatch(part).lbph{ep}	= data(3:end,rap(k)); % only lpb hist.
                    max_txpatch(part).numel{ep}	= dim_cluster(k);
                    ep = ep + 1;
                end
            end
        catch % if no epitome is found
            max_txpatch(part).patch	= [];
            max_txpatch(part).entr	= [];
            max_txpatch(part).w_ncc	= [];
            max_txpatch(part).pos		= [];
            max_txpatch(part).lbph	= [];
            max_txpatch(part).numel	= [];
        end
        
        % plotting
        if plotY
            clf(gcf)
            iii = 1;
            subplot(2,12,iii);imagesc(squeeze(dataset(:,:,:,i))), axis image;
            iii = 2;
            if ~isempty(epitome.patch)
                [v,order] = sort(clust_res,'descend');
                for p = 1:min(size(epitome.entr,2),11)
                    subplot(2,12,iii);imagesc(epitome.patch{order(p)}), axis image
                    title(['class ' num2str(clust_res(order(p)))])
                    iii = iii +1;
                end
            end
            iii = 13;
            if ~isempty(max_txpatch(i,ppart).patch)
                iii = iii + 1;
                for k = 1:min(length(max_txpatch(i,ppart).patch),11)
                    subplot(2,12,iii);imagesc(max_txpatch(i,ppart).patch{k}), axis image
                    title(['class ' num2str(k) ' numel ' num2str(max_txpatch(i,ppart).numel{k})])
                    iii = iii +1;
                end
            end
            drawnow;
            %pause
        end
        
        ppart = ppart + 1;
        
    else
        patches = [];
        max_txpatch(part).patch	= [];
        max_txpatch(part).entr	= [];
        max_txpatch(part).w_ncc	= [];
        max_txpatch(part).pos		= [];
        max_txpatch(part).lbph	= [];
        max_txpatch(part).numel	= [];
    end
    
    clear rap data BBox epitome
end
assert(size(max_txpatch,2) == 3)
TxPatch=max_txpatch';
% output: max_txpatch
