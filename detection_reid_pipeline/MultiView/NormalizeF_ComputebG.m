%% Normalize to desired normalizationType
Fmatrix = normalize_feat(m, Fmatrix, normalizationType);

% Normalize features to max value 1 (just scale them all by the max value)
% for mIt=1:m
%     Fmatrix{mIt} = Fmatrix{mIt}/max(abs(Fmatrix{mIt}(:)));
% end

%% bG square matrix size m*(u+l) : block matrix, with u+l blocks G(i,j)
% - each block G(i,j) is of size (m,m), is a diagonal matrix with
% Kernel_view1(samplei, samplej) and Kernel_view2(samplei, samplej) in the
% diagonal

% tic, fprintf(['Computing bG matrix... Sigmas are: ' num2str(s(1}) ' and ' num2str(s(2}) ' ']),
bGtstart=tic; fprintf(['Computing bG matrix... Sigmas are all 1 (so we save consistent bGs).. ']),
VECTORIZED = 0;
if VECTORIZED 
    %% "Fast" vectorized kernel code
        
    % ASSUMING TRAIN SAMPLES ARE ALL IN THE FIRST LINES OF F
    trainFmatrix = Fmatrix;
%     permids = randperm(u+l); % permute training examples = results do not change so much!!
    permids = 1:(u+l);
    for mIt = 1:m
        trainFmatrix{mIt,1} = trainFmatrix{mIt,1}(permids,:);
    end
    bG = computeBlockKernel(m, ones(size(s)), trainFmatrix); % computing bGs with sigmas == 1
    % DEBUG, computing bGs with sigmas == s
    % bG = computeBlockKernel(m, s, trainFmatrix); 
    
else 
    %% "SLOW" for-loop Kernel code 
    display(['running non-vectorized kernel code, kernelType ' kernelType])
    try % to allocate bG, if too large for memory, use sparse()
        bG = zeros(m*(u+l));
%         bG2 = zeros(m*(u+l));
    catch me
        try
            cprintf('error', 'Error: ');
            warning([me.message ' allocating bGs. Needed ' num2str(m*(u+l)*m*(u+l)/1024/1024/1024) 'GB..  Trying Single type' ])
            bG = zeros(m*(u+l),'single');            
        catch me
            % TODO: COMPUTE EXPECTED MEMORY USAGE AND DISPLAY (bG only has half
            % its elements filled by zeros)
            cprintf('error', 'Error: ');
            error([me.message ' ... Don''t even bother using sparse, you have a kron later on in the optimization that needs even more memory...'  ])
            warning([me.message ' allocating bGs. Needed ' num2str(m*(u+l)*m*(u+l)/1024/1024/1024/2) 'GB..  Using sparse' ])
            % bG = sparse(m*(u+l),m*(u+l));
            bG = spalloc(m*(u+l),m*(u+l), m*(u+l)*m*(u+l)/m);
        end
    end
    
    % TODO: bG is symmetric, take advantage of it below
    % ASSUMING TRAINING SAMPLES COME FIRST IN THE Fmatrix
    bGh = waitbar(0,'computing bG');
    for i=1:(u+l) % For all samples
        for j=1:(u+l) % For all samples
            
            G = zeros(m,m);
            for mIt=1:m % For all views
                K = Kernel(Fmatrix{mIt,1}(i,:), Fmatrix{mIt,1}(j,:), 1, Fmatrix{mIt,2}, i, j); % computing bG with sigmas == 1
                % DEBUG computing bG with sigma == s
                % K = Kernel(Fmatrix{mIt,1}(i,:), Fmatrix{mIt,1}(j,:), s(mIt), Fmatrix{mIt,2}, i, j); 
                G(mIt,mIt) = K;
            end
            
            bG(1+(i-1)*m : i*m , 1+(j-1)*m : j*m) = G;
        end
        %for j=1:(u+l) % For all samples
% TRIED TO SAVE TIME, ASSUMING bG IS SYMMETRIC (NOT SURE), BUT NOT WORKING        
%         for j=i:(u+l) % For all samples
%             
%             G = zeros(m,m);
%             for mIt=1:m % For all views
%                 K = Kernel(Fmatrix{mIt,1}(i,:), Fmatrix{mIt,1}(j,:), 1, Fmatrix{mIt,2}, i, j); % computing bG with sigmas == 1
%                 % DEBUG computing bG with sigma == s
%                 % K = Kernel(Fmatrix{mIt,1}(i,:), Fmatrix{mIt,1}(j,:), s(mIt), Fmatrix{mIt,2}, i, j); 
%                 G(mIt,mIt) = K;
%             end
%             
%             %bG(1+(i-1)*m : i*m , 1+(j-1)*m : j*m) = G;
%             bG2(1+(j-1)*m : j*m , 1+(i-1)*m : i*m) = G;
%         end
        waitbar(i/(u+l),bGh,['computing bG ' int2str(i) ' of ' int2str(u+l) ]);
    end
    close(bGh),
    inSparcity(bG)
%     inSparcity(bG2)
%     display(['bG-bG2: ' inSparcity(bG-bG2)])
end
toc(bGtstart),
