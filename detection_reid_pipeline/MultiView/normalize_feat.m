function Fmatrix_n = normalize_feat(m, Fmatrix, normType)

Fmatrix_n = Fmatrix; % to preserve kernelType flags in Fmatrix{:,2}
switch(normType)
    case 'mean0var1'
        for mIt=1:m
            % This seems a ver un-ellegant way to prevent normalization in
            % MSCR.. :( -Dario
            if  strcmp(Fmatrix_n{mIt,2},'MSCR')
                cprintf([0.5,0.5,1], 'MSCR feature matrix is actually the all2all distance matrix, \n so no normalization performed\n'),
                continue;
            end
                
            Fmatrix_n{mIt} = zeros(size(Fmatrix{mIt}));
            STD     = std(Fmatrix{mIt});
            MEAN    = mean(Fmatrix{mIt});
            Fmatrix_n{mIt}(:,MEAN~=0) = bsxfun(@minus,Fmatrix{mIt}(:,MEAN~=0),MEAN(MEAN~=0));
            Fmatrix_n{mIt}(:,MEAN~=0) = bsxfun(@rdivide,Fmatrix_n{mIt}(:,MEAN~=0),STD(:,MEAN~=0));
        end
        
        
    case 'allSumTo1'
        
        for mIt=1:m
            % This seems a ver un-ellegant way to prevent normalization in
            % MSCR.. :( -Dario
            if  strcmp(Fmatrix_n{mIt,2},'MSCR')
                cprintf([0.5,0.5,1], 'MSCR feature matrix is actually the all2all distance matrix, \n so no normalization performed\n'),
                continue;
            end
            for i=1:size(Fmatrix{mIt},1)
                Fmatrix_n{mIt}(i,:) = Fmatrix{mIt}(i,:)/sum(Fmatrix{mIt}(i,:));
            end
        end
        
    case 'halfSumTo1'  % for the binary formulation we normalize half vector
        for mIt=1:m
            % This seems a ver un-ellegant way to prevent normalization in
            % MSCR.. :( -Dario
            if  strcmp(Fmatrix_n{mIt,2},'MSCR')
                cprintf([0.5,0.5,1], 'MSCR feature matrix is actually the all2all distance matrix, \n so no normalization performed\n'),
                continue;
            end
            halfleng_feat = size(Fmatrix{mIt},2)/2;
            Fmatrix_n{mIt} = zeros(size(Fmatrix{mIt}));
            for i=1:size(Fmatrix{mIt},1)
                Fmatrix_n{mIt}(i,1:halfleng_feat) = Fmatrix{mIt}(i,1:halfleng_feat)/sum(Fmatrix{mIt}(i,1:halfleng_feat));
                Fmatrix_n{mIt}(i,halfleng_feat+1:end) = Fmatrix{mIt}(i,halfleng_feat+1:end)/sum(Fmatrix{mIt}(i,halfleng_feat+1:end));
            end
        end
        
    case ''
        % Do nothing
        
    otherwise
        error(['Unrecognized normalization type ' normType])
        
end