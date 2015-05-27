function K=calckernel_4(kernelType,s,X1,X2)

% CALCKERNEL Computes Gram matrix of a specified kernel on a given
% set of points X1 or between X1 and X2. This code is fully vectorized.
%
% K=calckernel_4(kernelType,s,X1)
% K=calckernel_4(kernelType,s,X1,X2)
%
% Inputs:
%
% X1 (X2 is optional) = a N x D data matrix
% (N examples, each of which is a D-dimensional vector)
%
% kernelType = 'linear' | 'poly' | 'rbf' | 'Gaussian' | 'Bhattacharyya' |
% 'Laplacian' | 'ChiSquare'
%
% s = specifies parameter for the kernel functions:
% 			degree for 'poly'; sigma for 'rbf', 'Gaussian',
% 			'Bhattacharyya', 'Laplacian', 'ChiSquare'; 
% 			can be ignored for linear kernel
%
%
% Outputs:
%
%  Given a single data matrix X1 (N xD)
%  returns Gram matrix K (N x N)
%
%  Given two data matrices X1 (N1 x D), X2 (N2 x D)
%  returns Gram matrix K (N1 x N2) (original verison by Vikas
%  returns matrix of size N2 x N1)
%
%  Author:  Minh (last updated October 31 2012)
%  Modified original version of  Vikas Sindhwani (vikass@cs.uchicago.edu)
%

tic;

if exist('X1','var')
    dim=size(X1,2);
    n1=size(X1,1);
end

if exist('X2','var')
    n2=size(X2,1);
end


%if ~isfield(options,'PointCloud')
%% so we dont intend to deform the kernel

%fprintf(1, 'Computing %s Kernel', kernelType); % Commented out by Minh
%
switch kernelType
    case 'linear'
        fprintf(1,'\n');
        if exist('X2','var')
            K=X1*X2';
        else
            K=X1*X1';
        end
        
    case 'poly'
        fprintf(1, ' of degree %d\n', s);
        if exist('X2','var')
            K=(X1*X2'+1).^s;
        else
            K=(X1*X1'+1).^s;
        end
        
    case 'Gaussian'
        
        %fprintf(1, ' of width %f\n', s); % Commented out by Minh
        if exist('X2','var')
            K = exp(-(repmat(sum(X1.*X1,2),1,n2) + repmat(sum(X2.*X2,2)',n1,1) ...
                - 2*(X1*X2'))/(s^2));
        else
            P=sum(X1.*X1,2);
            K = exp(-(repmat(P',n1,1) + repmat(P,1,n1) ...
                - 2*(X1*X1'))/(s^2));
        end
        
    case 'Bhattacharyya' % similar to Gaussian, but distance between sqrt(X1) and sqrt(X2)
        % properly normalized to have row sum = 1 (assuming nonnegative
        % entries
        %
        for i=1:n1
            X1(i,:) = X1(i,:)/sum(X1(i,:));
        end
        X1(isnan(X1)) = 0;
        X1 = sqrt(X1);
        
        if (exist('X2', 'var'))
            for i=1:n2
                X2(i,:) = X2(i,:)/sum(X2(i,:));
            end
            X2(isnan(X2)) = 0;
            X2 = sqrt(X2);
        end
        
        
        % Proceed as in the Gaussian case
        
        if exist('X2','var')
            K = exp(-(repmat(sum(X1.*X1,2),1,n2) + repmat(sum(X2.*X2,2)',n1,1) ...
                - 2*(X1*X2'))/(2*s^2));
        else
            P=sum(X1.*X1,2);
            K = exp(-(repmat(P',n1,1) + repmat(P,1,n1) ...
                - 2*(X1*X1'))/(2*s^2));
        end
        
    case 'Laplacian'
        error('This does not give the same result as the for-loop kernel')
        
        %fprintf(1, ' of width %f\n', s); % Commented out by Minh
        %if (length(s == 1)) % the default case
        %    s = [1 s];
        %end
        if exist('X2','var')
            K = (repmat(sum(X1.*X1,2),1, n2) + repmat(sum(X2.*X2,2)',n1,1) ...
                - 2*X1*X2');
            
            minK = min(K(:)); % Be careful here, this should be 0, but
            % numerically might be a very small negative number
            
            K = max(K, 0);
            %p = s(1);
            K = K .^ (1/2);
            %K = exp(-K/(s(2))^p);
            K = exp(-K/s^2);
            
        else
            
            P=sum(X1.*X1,2);
            K = repmat(P',n1,1) + repmat(P,1,n1) ...
                - 2*X1*X1';
            
            minK = min(K(:)); % Be careful here, this should be 0, but
            % numerically might be a very small negative number
            
            K = max(K, 0); % make sure this does not happen
            
            new_min_K = min(K(:)); % just testing
            
            display(s)
            
            %p = s(1);
            K = K .^ (1/2);
            %K = exp(-K/(s(2))^p);
            K = exp(-K/s^2);
        end
        
    case 'ChiSquare'
        warning('off','MATLAB:divideByZero')
        if (exist('X2', 'var'))
            K = zeros(n1, n2);
            for i=1:n2
                xi = X2(i,:);
                temp_xi = repmat(xi,n1,1);
                temp_xi = (X1 - temp_xi).^2 ./ (X1 + temp_xi);
                temp_xi(isnan(temp_xi)) = 0;
                temp_sum = sum(temp_xi, 2);
                K(:,i) = exp(-temp_sum/(2*s^2));
            end
        else
            K = zeros(n1, n1);
            for i=1:n1
                xi = X1(i,:);
                temp_xi = repmat(xi,n1,1);
                temp_xi = (X1 - temp_xi).^2 ./ (X1 + temp_xi);
                temp_xi(isnan(temp_xi)) = 0;
                temp_sum = sum(temp_xi, 2);
                K(:,i) = exp(-temp_sum/(2*s^2));
            end
            
        end
        warning('on','MATLAB:divideByZero')        
        
    otherwise
        
        error('Unknown Kernel Function.');
end


% else % we intend to deform our kernel
%     % this code can be speeded up later
%
%     opt.Kernel=options.Kernel;
%     opt.KernelParam=options.KernelParam;
%     X=options.PointCloud;
%     G=calckernel(opt,X);
%     if isfield(options,'DeformationMatrix')
%         M=options.DeformationMatrix;
%     else % use the laplacian
%         M=laplacian(options,X);
%         disp(['Using Iterated Laplacian of Degree ' num2str(options.LaplacianDegree)]);
%         M=(options.gamma_I/options.gamma_A)*(mpower(M,options.LaplacianDegree));
%
%     end
%
%     I=eye(size(G,1));
%     if exist('X1','var')
%         A=calckernel(opt,X1,X); % n x n1
%         if exist('X2','var')
%             B=calckernel(opt,X2,X); %n x n2
%             K1=calckernel(opt,X1,X2); % n2 x n1
%         else
%             B=A;
%             K1=calckernel(opt,X1);
%         end
%         disp('Deforming the Kernel');
%
%
%         K=(K1 - B'*((I+M*G)\M)*A);
%
%     else % we need gram matrix for the modified kernel over the point cloud
%         disp('Deforming the Kernel');
%         K=(I+G*M)\G;
%
%     end
%
% end

%disp(['Computation took ' num2str(toc) ' seconds.']); Commented out by
%Minh