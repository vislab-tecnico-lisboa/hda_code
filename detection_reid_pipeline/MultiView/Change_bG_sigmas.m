%% Changing sigmas after the deed (after having bG computed)
%
% Proof that e^(stuff/s) == (e^stuff).^1/s
% s=1
% rng(1)
% rabo1 = [exp(rand/s) 0 exp(rand/s) 0;
%     0 exp(rand/s) 0 exp(rand/s);
%     exp(rand/s) 0 exp(rand/s) 0;
%     0 exp(rand/s) 0 exp(rand/s);
%     ]
% 
% s=0.1
% rng(1)
% rabo01 = [exp(rand/s) 0 exp(rand/s) 0;
%     0 exp(rand/s) 0 exp(rand/s);
%     exp(rand/s) 0 exp(rand/s) 0;
%     0 exp(rand/s) 0 exp(rand/s);
%     ]
% rabo.^(1/0.1)


%DEBUG
% display('in Change bG Sigmas')
% info(bG)

% bGchangeTimein = tic;
for mit=1:m
    selector = zeros(1,m);
    selector(mit) = 1;
    selectorvector = logical(repmat(selector, 1, size(bG,1)/m));
%     bGm = bG(selectorvector,selectorvector).^(1/s(mit));
    bGm = bG(selectorvector,selectorvector).^(1/s(mit)^2); % Minh
    bG(selectorvector,selectorvector) = bGm; 
    
    % Verify that bG's are meaningful
    % Must have median above zero (otherwise it's an identity matrix) and
    % must have median below 1, otherwize it's an all-ones matrix)

    %comparing to realmin (e-308)
    %hasmeaning = median(bGm(:)) > realmin && abs(median(bGm(:))-1) > realmin; 
    %assert(hasmeaning, ['this sigma' int2str(mit) '=' num2str(s(mit)) ' makes the kernel matrix meaningless (either identity, or all-ones)'])

    %comparing to eps (e-016)
    hasmeaning = median(bGm(:)) > eps && abs(median(bGm(:))-1) > eps; 
    % assert(hasmeaning, ['this sigma' int2str(mit) '=' num2str(s(mit)) ' makes the kernel matrix meaningless (either identity, or all-ones)'])
    if ~hasmeaning
        cprintf('err',['Change_bG_sigmas.m: this sigma' int2str(mit) '=' num2str(s(mit)) ' makes the kernel matrix meaningless (either identity, or all-ones)'])
    end

    % Confirm that each view's kernel matrix is positive definite while
    % we're at it
    % assert(isposdef(bGm), ['Kernel matrix for view ' int2str(mIt) ' NOT positive definite!! :O'])
    if ~isposdef(bGm)
        cprintf('err',['Change_bG_sigmas.m: Kernel matrix for view ' int2str(mit) ' in run ' int2str(nRun) ' NOT positive definite!! :O\n'])
        notPosDef = 1; % checked in test_BruteForceInputs.m
    else
%         notPosDef = 0;
    end
end
% fprintf('bG change time1 = '), toc(bGchangeTimein),
% display(['Set sigmas to ' num2str(s)])
