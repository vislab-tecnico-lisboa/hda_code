%% Heuristic to estimate adequate sigma for this feature
% with Bhattacharyya distance

medianS = zeros(m,1);
for mIt=1:m
    F = Fmatrix{mIt,1};
    [nImages,histLen] = size(F); % F should be nImages x histLen
    
    % calculate the Bhattacharyya distance between the histograms
    % d_{bhatt}(x,y) = sqrt(1 - \sum  
    Fd = double(F);
    normVec = realmin + sum(Fd,2); % vector with sum of each ped hist
    hists_i = sqrt(Fd ./ normVec(:,ones(1,histLen))); % each hist normalized to 1, sqrt'ed
    distF = real(sqrt(1 - hists_i * hists_i')); % each element squared, 1 - , sqrt'ed

    distFmatrixes{nRun,mIt} = distF;
    
    medianS(mIt) = sqrt(2*median(distF(:)));
    
end
