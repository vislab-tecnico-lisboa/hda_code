function D = bhattacharyya_dist(H1,H2)
% Actually called Hellinger's Distance
% 
% modified Bhattacharyya coefficient so it is a distance
% H1 and H2: unit-normalized matrixes (we force normalize them here anyway)
% sqrt of 1 - http://en.wikipedia.org/wiki/Bhattacharyya_distance

D = sqrt(1-sum(sum(sqrt(normalize_matrix(H1,1).*normalize_matrix(H2,1)))));
