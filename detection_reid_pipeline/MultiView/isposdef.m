function bol = isposdef(H)
% function bol = isposdef(H)
% 
% [R,p] = chol(H); % If H is positive definite, then p is 0. But if A is
%                    not positive definite, then p is a positive integer.
% bol = ~p;

[R,p] = chol(H);

bol = ~p;