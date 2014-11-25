%% Actual  optimization
% script/function estimatedLabels = my_Optimization(P,m,u,l,gI,gA, Mm, J,
% bG, C, Ymatrix, numClasses,numSamples)

gI=params_mv.gA;
gA = params_mv.gB;
% eq (22)
% BmatrixTime = tic; fprintf('Computing B matrix... '), % 83% of the time is spent here 
B = ((1/m^2)*(kron(J, ones(m,m))) + l*gI*kron(eye(u+l),Mm))*bG + l*gA*eye((u+l)*m);
% toc(BmatrixTime),

Yct = reshape(C'*Ymatrix, P, (u+l)*m);
Yc = Yct';

% tic, fprintf('Solving for A... '), 
if rcond(B) < 10^-15
    notPosDef = 1; % tested for in test_BruteForceInputs.m
end
A = B \ Yc;
At = A';
% toc,

%% Test phase:

% eq (33)
% Ktime = tic; fprintf('Kernel times A time = ');
KernelTimesA2 = At*bG;
KernelTimesA2 = KernelTimesA2(:);
% toc(Ktime);

% labelsTime = tic; fprintf('Estimating labels... '), 
estimatedLabelsold = zeros(numClasses,numSamples);
for sample=1:u+l
    estimatedLabelsold(:, sample) = C*KernelTimesA2((sample-1)*P*m +1: sample*P*m);
end
% toc(labelsTime),

