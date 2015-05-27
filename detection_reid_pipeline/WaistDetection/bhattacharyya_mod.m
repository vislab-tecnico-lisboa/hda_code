function D = bhattacharyya_mod(H1,H2)
% modified Bhattacharyya coefficient
% H1 and H2: unit-normalized vectors (we force normalize them here anyway)

if sum(H1(:)) == 1 && sum(H2(:)) == 1
    D = sqrt(1-sum(sum(sqrt(H1.*H2))));
else
    D = sqrt(1-sum(sum(sqrt(normalize_matrix(H1,1).*normalize_matrix(H2,1)))));
end