function N = normalize_matrix(M, mass)
%N = normalize_matrix(M, mass)
% makes all the elements of M sum to mass, default 1

if nargin == 1
    mass = 1;
end 

% if a cell array, recurse over it and return cell array with normalized
% contents
if iscell(M)
    for i=1:size(M,2)
        N{i} = normalize_matrix(M{i}, mass);
    end
    return;
end

total = sum(M(:));
if total == 0
    N=M;
    return;
end
N = M/abs(total/mass);

end