%% showk: function description
function [fullk] = showk(k, idx)
	fullk = zeros(size(idx, 1), 1);
	fullk(idx) = k;
