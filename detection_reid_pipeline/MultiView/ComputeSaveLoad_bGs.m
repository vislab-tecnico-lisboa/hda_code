%% ComputeSaveLoad_bGs
% Must compute them with sigmas = 1 so the saved matrixes are consistent

% It's a script being called by a script that declared the global
% variables, you don't need to re-declare them here
% global 1 bGs m J Mm u l C Ymatrix Y_gt P numClasses numSamples 
% global DONTDOPLOT DOPLOT oneFineTuneRunTime
% global manifold

% %Currently not save/loading bGs
% % if ~exist(bGsPath,'dir'), mkdir(bGsPath), end
% 
% sstr = [];
% % for sit=1:length(s)
% for sit=1:m
%    sstr = [sstr num2str(1) '_']; % Must compute bG's with sigmas = 1
% end
% if ~exist('unlabeled','var'), unlabeled = ''; end % Backwards compatibility
if ~exist('normalizationType','var') % to normalize Fmatrix{} in normalize_feat.m
    normalizationType = 'allSumTo1';
end
% 
% oldbGsfilepath = [bGsPath 'bGs_' experimentVersion '.mat'];
% bGsfilepath = [bGsPath '/bGs_' experimentVersion '.mat'];
% if exist(oldbGsfilepath,'file')
%     movefile(oldbGsfilepath,bGsfilepath)
%     warning(['Moving file: ' oldbGsfilepath ' to ' bGsfilepath])
% end
% 
% 
% % % Backwards compatibility - adding the 'eq(4 Parts)' to the file names
% % if ~exist(bGsfilepath, 'file') && exist(oldbGsfilepath, 'file')
% %     movefile(oldbGsfilepath, bGsfilepath);
% %     cprintf('_green',[' -- Renamed to add ' equalize parts ' \n']);
% % end
% 
% if recomputeAllCachedInformation
%     delete(bGsfilepath),
% end

clear medianSigmas,
clear bGs bG,
% if exist(bGsfilepath, 'file')
%     %load(bGsfilepath, 'bGs')
%     load(bGsfilepath, 'bGs','medianSigmas')
%     if ~exist('bGs', 'var')
%         warning(['no bGs inside ' bGsfilepath '... deleting it.'])
%         delete(bGsfilepath)
%     else
% 
%         % Backwards compatibility - compute medianSigmas if not yet
%         if ~exist('medianSigmas','var') || isempty(medianSigmas)
%             cprintf(-[1,0,1],'medianSigmas not computed yet, computing and saving..\n');
%             for nRun = 1:1 % 1 % 1 loaded from partition mat file
%                 for mIt=1:m
%                     Fmatrix{mIt,1}=AllFMatrixMviews{nRun,mIt,1};
%                     % Set the custom kernelType for each view
%                     run SetCustomKernelForEachView,
%                 end
% 
%                 run ComputeMedianSigmas,
%                 medianSigmas(:,nRun) = medianS;
%             end % computing the median sigmas
%             save(bGsfilepath, 'bGs', 'medianSigmas')
%         end        
% 
%         cprintf('hyper','Loaded bGs and medianSigmas from')
%         display([' ' bGsfilepath])
%         % info(bGs)
%     end
% end
    
% if ~exist('bGs', 'var')
    %% Cell to ease "Run bGs anyway"
% No longer using bGs, just one bG    
%     try % allocate bGs matrix, if too large for memmory, try use sparse()
%         bGs = zeros(m*(u+l),m*(u+l),1);
%     catch me
%         cprintf('error', [me.message ' allocating bGs.'])
%         cprintf(' Using sparse\n')
% %         bGs = spalloc(m*(u+l),m*(u+l),nzmax);
%         bGs = sparse(m*(u+l),m*(u+l),1);
%     end
    for nRun = 1:1 % 1 % 1 loaded from partition mat file
        for mIt=1:m
            Fmatrix{mIt,1}=AllFMatrixMviews{nRun,mIt,1};
            % Set the custom kernelType for each view
            % run SetCustomKernelForEachView,
            % if there is no custom kernelType in AllFMatrixMviews set the default
            % display([me.message ' No custom kernelType defined, setting Fmatrix{' int2str(mIt) ',2} = ' kernelType])
            kernelType = 'Bhattacharyya';
            Fmatrix{mIt,2} = kernelType;        
        end
        
        ComputeMedianSigmas,
        medianSigmas(:,nRun) = medianS;
    %end %DEBUG computing the median
        NormalizeF_ComputebG,
        % bGs(:,:,nRun) = bG;
        
        % Verify that bG's are meaningful
        for mIt=1:m
            selector = zeros(1,m);
            selector(mIt) = 1;
            selectorvector = logical(repmat(selector, 1, size(bG,1)/m));
            bGm = bG(selectorvector,selectorvector);
            
            % Verify that bG's are meaningful
            % Must have median above zero (otherwise it's an identity matrix) and
            % must have median below 1, otherwize it's an all-ones matrix)
            hasmeaning = median(bGm(:)) > realmin && abs(median(bGm(:))-1) > realmin;
            %hasmeaning = hasmeaning &&  median(bGm(:)) < realmin || abs(median(bGm(:))-1); % BUG HERE? WHAT WAS THIS LINE FOR?  
            assert(hasmeaning, ['this sigma' int2str(mIt) '= 1' ... 
                ' makes the kernel matrix meaningless (either identity, or all-ones)'])
            
            % Confirm that each view's kernel matrix is positive definite while
            % we're at it
            % assert(isposdef(bGm), ['Kernel matrix for view ' int2str(mIt) ' NOT positive definite!! :O'])
            if ~isposdef(bGm),
                cprintf('err',['ComputeSaveLoad_bGs.m: Kernel matrix for view ' int2str(mIt) ' NOT positive definite!! :O\n'])
            end
        end
%     end
    
    % save(bGsfilepath, 'bGs', 'medianSigmas')
%     rabo = load(bGsfilepath, 'bGs','medianSigmas')
    
%     cprintf('_red','Saved bGs to')
%     display([' ' bGsfilepath])
    % save(bGsfilepath, 'bGs', '-v7.3')
    
    % DEBUG
    % fprintf('saved THIS bGs '), size(bGs)
    
end
