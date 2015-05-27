function [bG] = computeBlockKernel(m, s, Fmatrix1, Fmatrix2)

if ~exist('Fmatrix2', 'var')
    Fmatrix2 = Fmatrix1;
else
    assert(strcmp(Fmatrix1{1,2}, Fmatrix2{1,2}), 'kernelType not the same for the two matrixes.')
end

% fprintf(['Computing kernel matrix...\n']),    

size1 = size(Fmatrix1{1},1);
size2 = size(Fmatrix2{1},1);
% TODO assert size(Fmatrix1{1:m},1) are all the same, and also for Fmatrix1
bG = zeros(m*size1, m*size2);
clear G;
for mit=1:m
    
    current_kernel = Fmatrix1{mit,2};
    current_s = s(mit);
   
    if (~exist('Fmatrix2', 'var'))
        G{mit} = calckernel_4(current_kernel, current_s, Fmatrix1{mit},1);
    else
        G{mit} = calckernel_4(current_kernel, current_s, Fmatrix1{mit,1}, Fmatrix2{mit,1});
    end
    
    selector = zeros(1,m);
    selector(mit) = 1;
    bG = bG + kron(G{mit}, selector'*selector);
end
    
