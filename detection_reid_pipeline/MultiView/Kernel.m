function K = Kernel(x, xp, s, kernelType, i, j)
% function K = rancoKernel(x, xp, [s=1000])
% 
% 

if ~exist('s','var')
    s = 1;
end
if ~exist('kernelType','var')
    kernelType = 'Gaussian';
end

if strcmp(kernelType,'Gaussian')
    K = exp(-norm(x-xp)^2 / s^2 );
elseif strcmp(kernelType,'Bhattacharyya') % Actually Hellingers Distance
    K = exp(-bhattacharyya_dist(x,xp)^2 / s^2 );    
elseif strcmp(kernelType,'ChiSquare') 
    % K(t,x)= exp(-\frac{\sum\frac{(t_i-x_i)^2}{t_i+x_i}}{\sigma^2})
    K = exp(-ChiSqDistance(x,xp) / s^2 );    
elseif strcmp(kernelType,'Laplacian')
    error('This does not give the same result as the calckernel.m ')
    %K = exp(-sum(abs(x-xp)) / s^2 ); % Minh said Laplacian was p-norm with p=1 and now thinks this is not Laplacian
    K = exp(-norm(x-xp)/s^2); % Minh
elseif strcmp(kernelType,'MSCR')
    %if ~exist('j','var')
    %    error('You forgot to add the input ''j'' to Kernel(x, xp, s, kernelType, i, j)'),
    %end
    K = exp(-x(j) / s^2 ); % x is the ith line of distM. dist between i and j is the jth position of x
else
    error(['Unrecognized kernel type ' kernelType])
end