function [fgk, bgk] = clusterFromSaliency(sal1d, fgIdx, K)
	% Get initial cluster using only saliency map
	% [h, w] = size(saliency);
	sal1d_fg = sal1d(fgIdx);
	sal1d_bg = sal1d(~fgIdx);

	% rmpath(genpath('../vlfeat-0.9.20'));
	fgk = kmeans(sal1d_fg, K, 'Distance', 'cityblock', 'Replicates', 5);
	bgk = kmeans(sal1d_bg, K, 'Distance', 'cityblock', 'Replicates', 5);
	% addpath(genpath('../vlfeat-0.9.20'));
	% sal1d(lb1d) = fgk; sal1d(~lb1d) = bgk;
