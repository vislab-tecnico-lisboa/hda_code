function rankedListConcatenated = MultiViewold_RepeatWrapper(lstack, ustackOriginal, params_mv, viewlist, trainingDataStructure, filteredTestStruct, filteredCropsMat, memoryLimit, unlabeledLimit)

% test if it is used anywhere else, it is, it is used to check which camera
% we're testing on, to set the path where bGs would be save/loaded. But
% we're not save/loading bGs atm
%clear filteredTestStruct,

if ~exist('memoryLimit','var')
    memoryLimit = 22500;
end
if ~exist('unlabeledLimit','var')
    unlabeledLimit = [];
end
verbose = 0; % So it won't print "Computing bG matrix.." and "numSamples=..."

if size([lstack{1}, ustackOriginal{1}]',1)*length(viewlist) > memoryLimit
    % need to divide the unlabeled samples
    warning([int2str(size([lstack{1}, ustackOriginal{1}]',1)) ' samples with ' int2str(length(viewlist)) ' views is too large, able to compute bG but then "Error in kron", therefore we are dividing the unlabeled samples in 2 sets, and running multi-view twice (one for each set, both with the labeled samples).'])
    
    for mIte=1:length(viewlist)
        ustack{mIte} = ustackOriginal{mIte}(:,1:floor(end/2));
    end
    %     MultiViewcodeproper_oldVersion,
    rankedList = MultiViewold_RepeatWrapper(lstack, ustack, params_mv, viewlist, trainingDataStructure, filteredTestStruct, filteredCropsMat, memoryLimit, unlabeledLimit);
    rankedListConcatenated = rankedList;
    
    for mIte=1:length(viewlist)
        ustack{mIte} = ustackOriginal{mIte}(:,floor(end/2+1):end);
    end
    %     MultiViewcodeproper_oldVersion,
    rankedList = MultiViewold_RepeatWrapper(lstack, ustack, params_mv, viewlist, trainingDataStructure, filteredTestStruct, filteredCropsMat, memoryLimit, unlabeledLimit);
    rankedListConcatenated = [rankedListConcatenated rankedList];
else
    if ~exist('unlabeledLimit','var') || isempty(unlabeledLimit)
        % Do the regular way
        ustack = ustackOriginal;
        MultiViewcodeproper_oldVersion,
        rankedListConcatenated = rankedList;
        return,
    else
        rankedListConcatenated = [];
        global test1usample_at_a_time,
        if exist('test1usample_at_a_time','var') && test1usample_at_a_time
            wbr = waitbar(0, ['bG matrix , sample 0/' int2str(size(ustackOriginal{1}',1))]);            
            for usample = 1:size(ustackOriginal{1}',1)
                waitbar(usample/size(ustackOriginal{1}',1), wbr, ['bG matrix , sample ' int2str(usample) '/' int2str(size(ustackOriginal{1}',1))]);
                for mIte=1:length(viewlist)
                    % take the usample and the previous samples to a total of unlabeledLimit samples
                    ustack{mIte} = ustackOriginal{mIte}(:,max(1,usample-(unlabeledLimit-1)):usample);
                end
                MultiViewcodeproper_oldVersion,
                rankedListConcatenated = [rankedListConcatenated rankedList(:,end)];
                
            end
            close(wbr);
        else
            wbr = waitbar(0, ['bG matrix , sample 0/' int2str(size(ustackOriginal{1}',1))]);
            for usampleWindowEnd = unlabeledLimit:unlabeledLimit:size(ustackOriginal{1}',1)
                waitbar(usampleWindowEnd/size(ustackOriginal{1}',1), wbr, ['bG matrix , sample ' int2str(usampleWindowEnd) '/' int2str(size(ustackOriginal{1}',1))]);

                % take unlabeledLimit usamples to train per round
                for mIte=1:length(viewlist)
                    ustack{mIte} = ustackOriginal{mIte}(:,usampleWindowEnd-unlabeledLimit+1:usampleWindowEnd);
                end
                MultiViewcodeproper_oldVersion,
                rankedListConcatenated = [rankedListConcatenated rankedList];
            end
            close(wbr);

            % if there is a remainder
            if usampleWindowEnd ~= size(ustackOriginal{1}',1)
%                 % do the remainder (less than unlabeledLimit usamples)
%                 for mIte=1:length(viewlist)
%                     ustack{mIte} = ustackOriginal{mIte}(:,usampleWindowEnd+1:end);
%                 end
%                 MultiViewcodeproper_oldVersion,
%                 rankedListConcatenated = [rankedListConcatenated rankedList];

                % do the remainder but with unlabeledLimit usamples, and
                % then only take the remainder for the rankedList
                for mIte=1:length(viewlist)
                    ustack{mIte} = ustackOriginal{mIte}(:,end-unlabeledLimit+1:end);
                end
                MultiViewcodeproper_oldVersion,
                rankedListConcatenated = [rankedListConcatenated rankedList(:,end-(size(ustackOriginal{1}',1)-usampleWindowEnd)+1:end)];
            end
        end
        
        
    end
    
end




% display('rabo!!')